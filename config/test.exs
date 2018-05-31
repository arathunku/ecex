use Mix.Config
config :ecex, task_supervisor: Ecex.TaskTestSupervisor

config :ecex, Ecex.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ecex_test",
  username: "postgres",
  password: "postgres",
  hostname: "0.0.0.0",
  pool: Ecto.Adapters.SQL.Sandbox,
  port: "5432"
