defmodule BamboohrApi.Entity.Employee do
  @moduledoc """
  Corresponding elixir wrapper around BamboohrApi Employee endpoint
  """

  use BamboohrApi.Entity,
    enforce_keys: ~w(
      firstName
      id
      lastName
    )a,
    optional_keys: ~w(
      birthday
      canUploadPhoto
      department
      displayName
      division
      facebook
      gender
      jobTitle
      linkedIn
      location
      middleName
      mobilePhone
      payPer
      payRate
      photoUploaded
      photoUrl
      preferredName
      skypeUsername
      supervisor
      twitterFeed
      workEmail
      workPhone
      workPhoneExtension
    )a,
    actions: [
      list: [
        method: :GET,
        expected_resp_codes: [200],
        path_fn: fn _ -> "employees/directory" end
      ],
      get: [
        method: :GET,
        expected_resp_codes: [200],
        path_fn: fn %{id: id} -> "employees/#{id}/" end,
        required_keys: ~w(id fields)a
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
      true ->
        from_resp_params(response.body["employees"])

      false ->
        {:error, {response.status, response.body}}
    end
  end

  def resolve_response(action_name, resp) do
    super(action_name, resp)
  end
end
