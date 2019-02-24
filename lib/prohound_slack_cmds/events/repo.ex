defmodule ProhoundSlackCmds.Event.Repo do
  import ProhoundSlackCmds.Repo

  @count_query ~S"""
  SELECT count(*) FROM event_store_events
  """

  @delete_evts ~S"""
  DELETE FROM event_store_events where created_at < (now() - INTERVAL '<%= time_ago %>')
  """

  def count do
    case exec_query(@count_query) do
      {:ok, result} ->
        result
        |> zip_columns_and_rows()
        |> hd
        |> Map.get(:count)

      {:error, message} ->
        IO.puts(message)
        -1
    end
  end

  def delete_all(time_ago \\ "1 day") do
    r =
      EEx.eval_string(@delete_evts, time_ago: time_ago)
      |> exec_query()

    case r do
      {:ok, result} ->
        Map.get(result, :num_rows)

      {:error, message} ->
        IO.puts(message)
        -1
    end
  end
end
