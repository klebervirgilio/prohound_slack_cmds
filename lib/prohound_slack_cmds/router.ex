defmodule ProhoundSlackCmds.Router do
  use Plug.Router

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/sc" do
    url = Map.get(conn.params, "response_url") |> URI.decode()

    Task.start(fn -> ProhoundSlackCmds.SmartCentre.Slack.post(url) end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
  end

  post "/ce" do
    url = Map.get(conn.params, "response_url") |> URI.decode()

    Task.start(fn -> ProhoundSlackCmds.Event.Slack.count(url) end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
  end

  post "/de" do
    url = Map.get(conn.params, "response_url") |> URI.decode()
    text = Map.get(conn.params, "text", "5 days") |> URI.decode()

    Task.start(fn -> ProhoundSlackCmds.Event.Slack.delete(url, text) end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
  end

  post "/se" do
    url = Map.get(conn.params, "response_url") |> URI.decode()
    text = Map.get(conn.params, "text") |> URI.decode()

    Task.start(fn -> ProhoundSlackCmds.Event.Slack.latest(url, text) end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
