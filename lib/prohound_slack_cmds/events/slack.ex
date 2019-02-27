defmodule ProhoundSlackCmds.Event.Slack do
  alias ProhoundSlackCmds.Event.Repo
  alias ProhoundSlackCmds.HTTP
  alias ProhoundSlackCmds.Event.ES

  def count(url, text \\ nil) do
    case Poison.encode(%{text: "Count: #{Repo.count()}"}) do
      {:ok, json} -> HTTP.post(url, json)
    end
  end

  def delete(url, nil), do: delete(url, "10 days")
  def delete(url, ""), do: delete(url, "10 days")

  def delete(url, time_ago) do
    case Poison.encode(%{text: "Rows: #{Repo.delete_all(time_ago)}"}) do
      {:ok, json} -> HTTP.post(url, json)
    end
  end

  def latest(url, text) do
    [stream, event_type] = String.split(text)
    raw = ES.latest(stream, event_type)

    {:ok, json} = Poison.encode(raw, pretty: true)

    case Poison.encode(%{text: "```#{json}```"}) do
      {:ok, json} -> HTTP.post(url, json)
    end
  end
end
