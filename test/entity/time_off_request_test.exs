defmodule BamboohrApi.Entity.TimeOffRequestTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @module BamboohrApi.Entity.TimeOffRequest

  describe "@behaviour BamboohrApi.Entity" do
    test "behaves like BamboohrApi.Entity" do
      behaviour_modules =
        :attributes
        |> @module.__info__()
        |> Keyword.get(:behaviour)

      assert Enum.member?(behaviour_modules, BamboohrApi.Entity)
    end
  end

  describe ".get/2" do
    setup do
      ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
      :ok
    end

    test "gets time off requests between given dates when successful" do
      use_cassette "time_off_request/get/valid" do
        config = BamboohrApi.Config.default()
        {:ok, start} = Date.new(2020, 10, 28)
        {:ok, endd} = Date.new(2020, 11, 2)

        params = %{start: start, end: endd}

        time_off_requests = @module.get(params, config)

        assert time_off_requests == expected_time_off_requests_from_get()
      end
    end

    test "handles error when unsuccessful" do
      use_cassette "time_off_request/get/invalid" do
        config = BamboohrApi.Config.default()
        {:ok, start} = Date.new(2020, 10, 28)
        {:ok, endd} = Date.new(2020, 11, 2)

        params = %{start: start, end: endd}

        {:error, {status, body}} = @module.get(params, config)

        assert status == 404
        assert body == %{"error" => "Not Found"}
      end
    end

    test "returns error when no dates are given" do
      config = BamboohrApi.Config.default()

      params = %{}

      {:error, reason} = @module.get(params, config)

      assert reason == :required_keys_not_present
    end
  end

  defp expected_time_off_requests_from_get do
    [
      %BamboohrApi.Entity.TimeOffRequest{
        actions: %{
          "approve" => true,
          "bypass" => true,
          "cancel" => true,
          "deny" => true,
          "edit" => true,
          "view" => true
        },
        amount: %{"amount" => "3", "unit" => "days"},
        approvers: nil,
        balanceOnDateOfRequest: nil,
        comments: nil,
        created: "2020-09-21",
        dates: %{
          "2020-10-29" => "1",
          "2020-10-30" => "1",
          "2020-10-31" => "0",
          "2020-11-01" => "0",
          "2020-11-02" => "1"
        },
        employeeId: "1",
        end: "2020-11-02",
        id: "2020",
        name: "Albus Dumbledore",
        notes: %{"employee" => "Need to hunt Horcruxes! "},
        policyType: nil,
        start: "2020-10-29",
        status: %{
          "lastChanged" => "2020-09-21",
          "lastChangedByUserId" => "1",
          "status" => "requested"
        },
        type: %{
          "icon" => "time-off-calendar",
          "id" => "83",
          "name" => "Vacation"
        },
        usedYearToDate: nil
      },
      %BamboohrApi.Entity.TimeOffRequest{
        actions: %{
          "approve" => false,
          "bypass" => false,
          "cancel" => true,
          "deny" => false,
          "edit" => true,
          "view" => true
        },
        amount: %{"amount" => "2", "unit" => "days"},
        approvers: nil,
        balanceOnDateOfRequest: nil,
        comments: nil,
        created: "2020-09-21",
        dates: %{
          "2020-10-30" => "1",
          "2020-10-31" => "0",
          "2020-11-01" => "0",
          "2020-11-02" => "1"
        },
        employeeId: "2222",
        end: "2020-11-02",
        id: "2021",
        name: "Harry Potter",
        notes: [],
        policyType: nil,
        start: "2020-10-30",
        status: %{
          "lastChanged" => "2020-09-21",
          "lastChangedByUserId" => "2222",
          "status" => "approved"
        },
        type: %{
          "icon" => "time-off-calendar",
          "id" => "83",
          "name" => "Vacation"
        },
        usedYearToDate: nil
      }
    ]
  end
end
