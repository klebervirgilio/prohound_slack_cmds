defmodule ProhoundSlackCmds.SmartCentre.Model do
  alias ProhoundSlackCmds.SmartCentre.Repo
  alias ProhoundSlackCmds.SmartCentre.ES

  defstruct account_id: nil,
            account_name: nil,
            branch: nil,
            group: nil,
            machine: nil,
            machine_id: nil,
            registration_code: nil,
            latest_sync: nil

  def all do
    Repo.find_all() |> Enum.map(&model_from_map/1) |> with_latest_sync()
  end

  def with_latest_sync(smart_centres) do
    smart_centres
    |> Enum.map(&fetch_latest_sync/1)
    |> Enum.map(&Task.await/1)
  end

  def fetch_latest_sync(smart_centre) do
    Task.async(fn ->
      latest_sync = ES.latest_sync(smart_centre.registration_code) |> convert_timestamp()
      %{smart_centre | latest_sync: latest_sync}
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
