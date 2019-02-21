defmodule ProhoundSlackCmds.SmartCentre.Model do
  alias ProhoundSlackCmds.SmartCentre.Repo

  defstruct registration_code: nil,
            account_id: nil,
            machine_id: nil,
            name: nil,
            title: nil,
            last_sync: nil

  def all do
    Repo.find_all() |> Enum.map(&model_from_map/1)
  end

  def model_from_map(map) do
    struct(__MODULE__, map)
  end
end
