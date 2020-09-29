defmodule BamboohrApi.Entity do
  @moduledoc """
  Base Entity for BamboohrApi
  """

  @callback path(
              request_type :: atom(),
              params :: map()
            ) :: {:ok, String.t()} | {:error, term()}

  @callback required_keys(request_type :: atom()) :: list(atom())

  @callback resolve_response(request_type :: atom(), term()) :: term()

  defmacro __using__(opts) do
    actions = Keyword.get(opts, :actions, [])

    quote do
      @behaviour unquote(__MODULE__)

      def request(type, params, config, method) do
        with true <- required_keys_present?(type, params),
             {:ok, path} <- path(type, params),
             {:ok, client} <- build_client(config),
             {:ok, response} <- http(method, client, path, params) do
          resolve_response(type, response)
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

      defp required_keys_present?(request_type, params) do
        request_type
        |> required_keys()
        |> Enum.all?(&Map.get(params, &1, nil))
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
    end
  end
end
