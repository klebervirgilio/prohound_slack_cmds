defmodule ProhoundSlackCmds.Router do
  use Plug.Router

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/sc" do
    url = Map.get(conn.params, "response_url") |> URI.decode()
    spawn fn ->
      ProhoundSlackCmds.SmartCentre.Slack.post(url)
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
