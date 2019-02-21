defmodule ProhoundSlackCmds.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Postgrex,
       Keyword.put(Application.get_env(:prohound_slack_cmds, :db), :name, ProhoundSlackCmds.DB)},
      Plug.Cowboy.child_spec(scheme: :http, plug: ProhoundSlackCmds.Router, options: [port: 4001])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProhoundSlackCmds.Supervisor]
    Logger.info("Starting application...")
    Supervisor.start_link(children, opts)
  end
end
