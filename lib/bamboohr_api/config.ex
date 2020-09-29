defmodule BamboohrApi.Config do
  @moduledoc """
  Config module for Bamboohr API
  """

  @type t :: %__MODULE__{subdomain: String.t(), api_key: String.t(), api_version: String.t()}

  @enforce_keys ~w(subdomain api_key api_version)a

  defstruct @enforce_keys

  @doc """
  Returns default configuration for `:bamboohr_api` Application. This can
  be updated by setting a different `env` for `:bamboohr_api` app.
  """
  @spec default :: t()
  def default do
    params =
      :bamboohr_api
      |> Application.get_env(BamboohrApi.Config)
      |> Enum.into(%{})

    struct!(__MODULE__, params)
  end
end
