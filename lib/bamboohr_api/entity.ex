defmodule BamboohrApi.Entity do
  @moduledoc """
  Base Entity for BamboohrApi
  """

  @callback request(
              action :: atom(),
              params :: map(),
              config :: BamboohrApi.Config.t(),
              method :: atom()
            ) :: map() | list(map()) | {:error, term()}

  @callback resolve_response(action :: atom(), term()) :: term()

  defmacro __using__(opts) do
    actions = Keyword.get(opts, :actions, [])
    enforce_keys = Keyword.get(opts, :enforce_keys, [])
    optional_keys = Keyword.get(opts, :optional_keys, [])

    ast =
      quote do
        defp required_keys_present?(action, params) do
          action_params = Keyword.get(actions(), action)

          action_params
          |> Keyword.get(:required_keys, [])
          |> Enum.all?(&Map.get(params, &1, nil))
        end

        defp path(action, params) do
          action_params = Keyword.get(actions(), action)

          fun = Keyword.get(action_params, :path_fn)

          try do
            {:ok, fun.(params)}
          rescue
            RuntimeError -> {:error, :error_in_resolving_path}
          end
        end
      end

    [
      define_struct(enforce_keys, optional_keys),
      add_behaviour(actions),
      ast
    ] ++ define_action_functions(actions)
  end

  def define_struct(enforce_keys, optional_keys) do
    quote do
      @enforce_keys unquote(enforce_keys)
      @optional_keys unquote(optional_keys)

      defstruct @enforce_keys ++ @optional_keys
    end
  end

  def add_behaviour(actions) do
    quote do
      alias BamboohrApi.TeslaHelpers, as: TH

      @behaviour unquote(__MODULE__)

      @impl true
      def request(action, params, config, method) do
        with :ok <- validate_action(action),
             true <- required_keys_present?(action, params),
             {:ok, path} <- path(action, params),
             {:ok, client} <- TH.build_client(config),
             {:ok, response} <- TH.http(method, client, path, params) do
          resolve_response(action, response)
        else
          false -> {:error, :required_keys_not_present}
          {:error, reason} -> {:error, reason}
        end
      end

      def actions do
        unquote(actions)
      end

      defp validate_action(action_name) do
        action_names = Keyword.keys(actions())

        case Enum.member?(action_names, action_name) do
          true -> :ok
          false -> {:error, :invalid_action}
        end
      end

      @impl true
      def resolve_response(action_name, %Tesla.Env{} = response) do
        action_params = Keyword.get(actions(), action_name)

        success =
          action_params
          |> Keyword.get(:expected_resp_codes, [])
          |> Enum.member?(response.status)

        case success do
          true -> from_resp_params(response.body)
          false -> {:error, {response.status, response.body}}
        end
      end

      defp from_resp_params(list) when is_list(list) do
        Enum.map(list, &from_resp_params/1)
      end

      defp from_resp_params(%{} = map) do
        atom_keys_map =
          map
          |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
          |> Enum.into(%{})

        struct!(__MODULE__, atom_keys_map)
      end

      defoverridable resolve_response: 2
    end
  end

  def define_action_functions(actions) do
    Enum.map(actions, fn {name, opts} ->
      method = Keyword.get(opts, :method, :GET)

      quote do
        def unquote(name)(params, config) do
          request(unquote(name), params, config, unquote(method))
        end
      end
    end)
  end
end
