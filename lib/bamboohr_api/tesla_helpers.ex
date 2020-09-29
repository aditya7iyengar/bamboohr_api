defmodule BamboohrApi.TeslaHelpers do
  @moduledoc false

  def http(:PUT, client, path, params) do
    Tesla.put(client, path, params)
  end

  def http(:POST, client, path, params) do
    Tesla.post(client, path, params)
  end

  def http(:GET, client, path, params) do
    Tesla.get(client, path, query: params)
  end

  def build_client(config) do
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
end
