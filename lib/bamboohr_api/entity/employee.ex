defmodule BamboohrApi.Entity.Employee do
  @moduledoc """
  Corresponding elixir wrapper around BamboohrApi Employee endpoint
  """

  use BamboohrApi.Entity,
    enforce_keys: ~w(
      id
      firstName
      middleName
      lastName
      preferredName
      workEmail
      birthday
      payRate
      payPer
    )a,
    actions: [
      get: [
        method: :GET,
        expected_resp_codes: [200],
        path_fn: fn %{id: id} -> "employees/#{id}/" end,
        required_keys: ~w(id fields)a
      ]
    ]
end
