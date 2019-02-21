defmodule ProhoundSlackCmds.Router do
  use Plug.Router

  alias ProhoundSlackCmds.SmartCentre.Model

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/sc" do
    {:ok, json} = Poison.encode(Model.all())

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
