defmodule ProhoundSlackCmds.Router  do
  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded]
  plug Plug.Logger
  plug :match
  plug :dispatch

  post "/sc" do
    IO.inspect conn.params
    send_resp(conn, 200, "world")
  end
end