defmodule ProhoundSlackCmds.SmartModule.Model do
  alias ProhoundSlackCmds.SmartModule.Repo
  alias ProhoundSlackCmds.SmartModule.ES

  defstruct account: nil,
            branch: nil,
            group: nil,
            machine: nil,
            id: nil,
            peer: nil,
            sensor_id: nil,
            sensor_location: nil,
            sensor_registration_code: nil,
            sensor_title: nil,
            sensor_type: nil,
            sensor_type_category: nil,
            latest_sync: nil

  def all do
    Repo.find_all() |> Enum.map(&model_from_map/1) |> with_latest_sync()
  end

  def with_latest_sync(smart_modules) do
    smart_modules
    |> Enum.map(&fetch_latest_sync/1)
    |> Enum.map(&Task.await/1)
  end

  def fetch_latest_sync(smart_module) do
    Task.async(fn ->
      latest_sync = ES.latest_sync(smart_module.id) |> convert_timestamp()
      %{smart_module | latest_sync: latest_sync}
    end)
  end

  def model_from_map(map) do
    struct(__MODULE__, map)
  end

  def convert_timestamp(timestamp) do
    case Timex.parse(timestamp, "{ISO:Extended}") do
      {:ok, date} -> date
      {:error, :badarg} -> nil
    end
  end
end
