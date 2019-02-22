use Mix.Config

port =
  case System.get_env("PORT") do
    port when is_binary(port) -> String.to_integer(port)
    # default port
    nil -> 443
  end

config :prohound_slack_cmds,
  port: port,
  es: %{
    url:
      "#{System.get_env("ELASTICSEARCH_URL")}/rails_event_store_active_record_events_production/_search?"
  },
  db: [
    pool: DBConnection.Poolboy,
    pool_size: 5,
    host: System.get_env("PGHOST"),
    username: System.get_env("PGUSER"),
    password: System.get_env("PGPASSWORD"),
    database: System.get_env("PGDATABASE")
  ]
