# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :worldbadges,
  ecto_repos: [Worldbadges.Repo]

# Configures the endpoint
config :worldbadges, WorldbadgesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3/uhZzIWEwD7fmyGccWj/NgqrD8eHGhAgfzIr7/9gnvecO4RFACzl+xORYnUrr6X",
  render_errors: [view: WorldbadgesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Worldbadges.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Guardian configuration
config :guardian, Guardian,
  issuer: "Worldbadges.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  serializer: WorldbadgesWeb.GuardianSerializer,
  secret_key: to_string(Mix.env) <> "SuPerseCret_aBraCadabrA_bis"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure ExAws
config :ex_aws,
  access_key_id: [System.get_env("S3_ACCESS_KEY_ID"), :instance_role],
  secret_access_key: [System.get_env("S3_SECRET_ACCESS_KEY"), :instance_role]
  scheme: "https://"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
