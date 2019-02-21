defmodule ProhoundSlackCmds.SmartCentre.Repo do
  @base_query ~S"""
  SELECT registration_code, gateways.account_id, machine_id, machines.title, groups.title, group_categories.name, accounts.name
  FROM gateways left join accounts on accounts.id = gateways.account_id
  left join machines on machines.id = gateways.machine_id
  left join groups on machines.group_id = groups.id
  left join group_categories on group_categories.id = groups.group_category_id
  """

  def find_all do
    :poolboy.transaction(
      ProhoundSlackCmds.DB,
      &(Postgrex.query!(&1, @base_query, []) |> zip_columns_and_rows)
    )
  end

  defp zip_columns_and_rows(%{rows: rows, columns: columns}) do
    columns = columns |> Enum.map(&String.to_atom/1)
    rows |> Enum.map(&zip_columns_row(columns, &1))
  end

  defp zip_columns_row(columns, row) do
    Enum.zip(columns, row) |> Map.new()
  end
end
