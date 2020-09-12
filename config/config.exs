# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :arena_liveview,
  ecto_repos: [ArenaLiveview.Repo]

# Configures the endpoint
config :arena_liveview, ArenaLiveviewWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZseIIAI5RoGfRnQ4wOl6pBbW0jN4PZXgLdS+WFwxaW9ApycQb8OYK3vE4WEZ/G7v",
  render_errors: [view: ArenaLiveviewWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ArenaLiveview.PubSub,
  live_view: [signing_salt: "RmFeVSHN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
