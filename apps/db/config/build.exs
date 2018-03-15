use Mix.Config

config :db, Innerpeace.Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  database: System.get_env("DB_NAME") || "payorlink_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool_size: 10
