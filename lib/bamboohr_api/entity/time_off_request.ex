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
end
