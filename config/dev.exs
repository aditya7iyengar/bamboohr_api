use Mix.Config

config :bamboohr_api, BamboohrApi.Config,
  subdomain: System.get_env("BAMBOO_SUBDOMAIN"),
  api_key: System.get_env("BAMBOO_API_KEY"),
  api_version: System.get_env("BAMBOO_API_VERSION")
