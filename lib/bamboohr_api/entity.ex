defmodule BamboohrApi.Entity do
  @moduledoc """
  Base Entity for BamboohrApi
  """

  @callback resolve_response(action :: atom(), term()) :: term()

  defmacro __using__(opts) do
    actions = Keyword.get(opts, :actions, [])
    enforce_keys = Keyword.get(opts, :enforce_keys, [])
    optional_keys = Keyword.get(opts, :optional_keys, [])

    ast1 =
      quote do
        @behaviour unquote(__MODULE__)

        @enforce_keys unquote(enforce_keys)
        @optional_keys unquote(optional_keys)

        defstruct @enforce_keys ++ @optional_keys

        def request(action, params, config, method) do
          with :ok <- validate_action(action),
               true <- required_keys_present?(action, params),
               {:ok, path} <- path(action, params),
               {:ok, client} <- build_client(config),
               {:ok, response} <- http(method, client, path, params) do
            resolve_response(action, response)
          else
            false -> {:error, :required_keys_not_present}
            {:error, reason} -> {:error, reason}
          end
        end

        defp http(:PUT, client, path, params) do
          Tesla.put(client, path, params)
        end

        defp http(:POST, client, path, params) do
          Tesla.post(client, path, params)
        end

        defp http(:GET, client, path, params) do
          Tesla.get(client, path, query: params)
        end

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

        defp build_client(config) do
          api_key = config.api_key

          middleware = [
            {Tesla.Middleware.BaseUrl, base_url_for_config(config)},
            Tesla.Middleware.JSON,
            # TODO: Make response type configurable json/xml
            {
              Tesla.Middleware.Headers,
              [
                {"Accept", "application/json"},
                {"content-type", "application/json"}
              ]
            },
            {Tesla.Middleware.BasicAuth, %{username: api_key, password: "x"}}
          ]

          {:ok, Tesla.client(middleware)}
        end

        defp base_url_for_config(%BamboohrApi.Config{} = config) do
          Path.join([bamboohr_api_url(), config.subdomain, config.api_version])
        end

        defp bamboohr_api_url do
          "https://api.bamboohr.com/api/gateway.php/"
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

    asts =
      Enum.map(actions, fn {name, opts} ->
        method = Keyword.get(opts, :method, :GET)

        quote do
          def unquote(name)(params, config) do
            request(unquote(name), params, config, unquote(method))
          end
        end
      end)

    [ast1 | asts]
  end
end
