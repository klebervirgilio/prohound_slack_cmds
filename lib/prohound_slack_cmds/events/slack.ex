defmodule ProhoundSlackCmds.Event.Slack do
  alias ProhoundSlackCmds.Event.Repo
  alias ProhoundSlackCmds.HTTP

  def count(url) do
    case Poison.encode(%{text: "Count: #{Repo.count()}"}) do
      {:ok, json} -> HTTP.post(url, json)
    end
  end

  def delete(url, time_ago \\ nil) do
    case Poison.encode(%{text: "Rows: #{Repo.delete_all(time_ago)}"}) do
      {:ok, json} -> HTTP.post(url, json)
    end
  end
end
