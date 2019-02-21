defmodule ProhoundSlackCmds.SmartCentre.Model do
  alias ProhoundSlackCmds.SmartCentre.Repo
  alias ProhoundSlackCmds.SmartCentre.ES

  defstruct registration_code: nil,
            account_id: nil,
            machine_id: nil,
            name: nil,
            title: nil,
            last_sync: nil

  def all do
    Repo.find_all() |> Enum.map(&model_from_map/1) |> with_last_sync()
  end

  def with_last_sync(smart_centres) do
    Enum.map(smart_centres, fn smart_centre ->
      Task.async(fn ->
        %{smart_centre | last_sync: ES.last_sync(smart_centre.registration_code)}
      end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def model_from_map(map) do
    struct(__MODULE__, map)
  end
end
