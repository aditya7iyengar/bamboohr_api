defmodule BamboohrApi do
  @moduledoc """
  Documentation for `BamboohrApi`.
  """

  alias __MODULE__.{Config, Entities.TimeOffRequest}

  @spec request_time_off(map(), Config.t()) :: :ok | {:error, term()}
  def request_time_off(params, config \\ nil) do
    config = config || default_config()

    TimeOffRequest.create(params, config)
  end

  defdelegate default_config, to: Config, as: :default
end
