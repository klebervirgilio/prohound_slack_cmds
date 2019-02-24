defmodule ProhoundSlackCmds.SmartCentre.Repo do
  import ProhoundSlackCmds.Repo

  @base_query ~S"""
  SELECT registration_code,
         gateways.id,
         gateways.account_id,
         machine_id,
         machines.title as machine,
         groups.title as group,
         group_categories.name as branch,
         accounts.name as account
  FROM gateways
  LEFT JOIN accounts on accounts.id = gateways.account_id
  LEFT JOIN machines on machines.id = gateways.machine_id
  LEFT JOIN groups on machines.group_id = groups.id
  LEFT JOIN group_categories on group_categories.id = groups.group_category_id
  """

  def find_all do
    case exec_query(@base_query) do
      {:ok, result} ->
        result
        |> zip_columns_and_rows()

      {:error, message} ->
        IO.puts(message)
        -1
    end
  end
end
