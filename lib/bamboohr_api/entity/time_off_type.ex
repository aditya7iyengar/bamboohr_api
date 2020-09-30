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
      list: [
        method: :GET,
        expected_resp_codes: [200],
        path_fn: fn _params -> "meta/time_off/types" end
      ]
    ]

  @impl true
  def resolve_response(:list, %Tesla.Env{} = response) do
    action_params = Keyword.get(actions(), :list)

    success =
      action_params
      |> Keyword.get(:expected_resp_codes, [])
      |> Enum.member?(response.status)

    case success do
      true -> from_resp_params(response.body["timeOffTypes"])
      false -> {:error, {response.status, response.body}}
    end
  end

  def resolve_response(action_name, resp) do
    super(action_name, resp)
  end
end
