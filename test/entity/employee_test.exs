defmodule BamboohrApi.Entity.EmployeeTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @module BamboohrApi.Entity.Employee

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

    test "gets employee with their respective fields" do
      use_cassette "employee/get/valid" do
        config = BamboohrApi.Config.default()

        fields =
          @module.__struct__()
          |> Map.keys()
          |> List.delete(:__struct__)
          |> Enum.join(",")

        params = %{id: 0, fields: fields}

        employees = @module.get(params, config)

        assert employees == expected_employee_from_get()
      end
    end

    test "handles error when unsuccessful" do
      use_cassette "employee/get/invalid" do
        config = BamboohrApi.Config.default()

        fields =
          @module.__struct__()
          |> Map.keys()
          |> List.delete(:__struct__)
          |> Enum.join(",")

        params = %{id: 0, fields: fields}

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

  defp expected_employee_from_get do
    %BamboohrApi.Entity.Employee{
      birthday: "10-10",
      firstName: "Harry",
      id: "2020",
      lastName: "Potter",
      middleName: "James",
      payPer: nil,
      payRate: nil,
      preferredName: nil,
      workEmail: "harry.potter@hogwarts.com"
    }
  end
end
