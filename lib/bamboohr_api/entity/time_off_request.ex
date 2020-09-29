defmodule BamboohrApi.Entity.TimeOffRequest do
  @moduledoc """
  Corresponding elixir wrapper around BamboohrApi TimeOffRequest endpoint
  """

  use BamboohrApi.Entity,
    actions: [
      {:get, method: :GET, expected_resp_codes: [200]},
      {:create, method: :PUT, expected_resp_codes: [201]}
    ]

  @enforce_keys ~w(
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
  )a

  @optional_keys ~w(
    approvers
    notes
    balanceOnDateOfRequest
    comments
    policyType
    usedYearToDate
  )a

  defstruct @enforce_keys ++ @optional_keys

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

  def create(params, config) do
    request(:create, params, config, :PUT)
  end

  def get(params, config) do
    request(:get, params, config, :GET)
  end

  @impl true
  def path(:get, _params), do: {:ok, "/time_off/requests"}

  def path(:create, %{employeeId: id}) do
    {:ok, "/employees/#{id}/time_off/request"}
  end

  def path(_, _), do: {:error, :path_not_defined}

  @impl true
  def required_keys(:get), do: ~w(start end)a
  def required_keys(:create), do: ~w(start end employeeId timeOffTypeId status)a
  def required_keys(_), do: []
end
