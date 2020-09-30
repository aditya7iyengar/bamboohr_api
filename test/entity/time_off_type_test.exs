defmodule BamboohrApi.Entity.TimeOffTypeTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @module BamboohrApi.Entity.TimeOffType

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

    test "gets time off types between given dates when successful" do
      use_cassette "time_off_type/get/valid" do
        config = BamboohrApi.Config.default()
        time_off_types = @module.get(%{}, config)

        assert time_off_types == expected_time_off_types_from_get()
      end
    end

    test "handles error when unsuccessful" do
      use_cassette "time_off_type/get/invalid" do
        config = BamboohrApi.Config.default()
        {:error, {status, body}} = @module.get(%{}, config)

        assert status == 404
        assert body == %{"error" => "Not Found"}
      end
    end
  end

  defp expected_time_off_types_from_get do
    [
      %BamboohrApi.Entity.TimeOffType{
        color: "4aada4",
        icon: "time-off-calendar",
        id: "83",
        name: "Vacation",
        units: "days"
      }
    ]
  end
end
