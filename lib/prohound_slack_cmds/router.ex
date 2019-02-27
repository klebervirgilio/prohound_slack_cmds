defmodule ProhoundSlackCmds.Router do
  use Plug.Router
  alias ProhoundSlackCmds.{SmartCentre, Event, SmartModule}

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  def exec_cmd(conn, cmd) do
    url = Map.get(conn.params, "response_url") |> URI.decode()
    text = Map.get(conn.params, "text") |> URI.decode()
    Task.start(fn -> cmd.(url, text) end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
  end

  post "/sc" do
    exec_cmd(conn, &SmartCentre.Slack.post/2)
  end

  post "/sm" do
    exec_cmd(conn, &SmartModule.Slack.post/2)
  end

  post "/ce" do
    exec_cmd(conn, &Event.Slack.count/2)
  end

  post "/de" do
    exec_cmd(conn, &Event.Slack.delete/2)
  end

  post "/se" do
    exec_cmd(conn, &Event.Slack.latest/2)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
