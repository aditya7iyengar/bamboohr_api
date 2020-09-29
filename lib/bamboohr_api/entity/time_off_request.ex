defmodule BamboohrApi.Entity.TimeOffRequest do
  @moduledoc """
  Corresponding elixir wrapper around BamboohrApi TimeOffRequest endpoint
  """

  use BamboohrApi.Entity,
    enforce_keys: ~w(
      actions
      amount
      created
      dates
      employeeId
      end
      id
      name
      start
      status
      type
    )a,
    optional_keys: ~w(
      approvers
      notes
      balanceOnDateOfRequest
      comments
      policyType
      usedYearToDate
    )a,
    actions: [
      get: [
        method: :GET,
        expected_resp_codes: [200],
        path_fn: fn _params -> "/time_off/requests" end,
        required_keys: ~w(start end)a
      ],
      create: [
        method: :PUT,
        expected_resp_codes: [201],
        path_fn: fn %{employeeId: id} ->
          "/employees/#{id}/time_off/request"
        end,
        required_keys: ~w(start end employeeId timeOffTypeId status)a
      ]
    ]

  @impl true
  def resolve_response(:get, %Tesla.Env{status: 200, body: body}) do
    Enum.map(body, &from_resp_params/1)
  end

  def resolve_response(:create, %Tesla.Env{status: 201, body: body}) do
    from_resp_params(body)
  end

  def resolve_response(_, %Tesla.Env{status: status, body: body}) do
    {:error, {status, body}}
  end

  defp from_resp_params(map) do
    atom_keys_map =
      map
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})

    struct!(__MODULE__, atom_keys_map)
  end
end
