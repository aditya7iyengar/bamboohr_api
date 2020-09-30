defmodule BamboohrApi.Entity.TimeOffType do
  @moduledoc """
  Corresponding elixir wrapper around BamboohrApi TimeOffType endpoint
  """

  use BamboohrApi.Entity,
    enforce_keys: ~w(
      id
      name
      units
      color
      icon
    )a,
    actions: [
      get: [
        method: :GET,
        expected_resp_codes: [200],
        path_fn: fn _params -> "meta/time_off/types" end
      ]
    ]

  @impl true
  def resolve_response(action_name, %Tesla.Env{} = response) do
    action_params = Keyword.get(actions(), action_name)

    success =
      action_params
      |> Keyword.get(:expected_resp_codes, [])
      |> Enum.member?(response.status)

    case success do
      true -> from_resp_params(response.body["timeOffTypes"])
      false -> {:error, {response.status, response.body}}
    end
  end
end
