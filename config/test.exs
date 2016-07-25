use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :eecrit, Eecrit.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your databases
config :eecrit, Eecrit.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  # password: "postgres",
  database: "eecrit_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :eecrit, Eecrit.OldRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  # password: "postgres",
  database: "critter4us_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Make encryption fast for tests
config :comeonin,
  bcrypt_log_rounds: 4,
  pbkdf2_rounds: 1
