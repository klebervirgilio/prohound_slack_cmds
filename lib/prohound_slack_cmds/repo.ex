defmodule ProhoundSlackCmds.Repo do
  def exec_query(query) do
    try do
      :poolboy.transaction(
        ProhoundSlackCmds.DB,
        &{:ok, Postgrex.query!(&1, query, [], timeout: 60_000)}
      )
    rescue
      e in DBConnection.ConnectionError -> {:error, e.message}
    end
  end

  def zip_columns_and_rows(%{rows: rows, columns: columns}) do
    columns = columns |> Enum.map(&String.to_atom/1)
    rows |> Enum.map(&zip_columns_row(columns, &1))
  end

  def zip_columns_row(columns, row) do
    Enum.zip(columns, row) |> Map.new()
  end
end
