use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :worldbadges, WorldbadgesWeb.Endpoint,
  secret_key_base: "AQK28lei+4zMvCWN93dMxXjolf9CJcz70RRwIeQ1A5hu5sTf6P2KdsAHju6gU+2f"

# Configure your database
config :worldbadges, Worldbadges.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "worldbadges_prod",
  pool_size: 15
