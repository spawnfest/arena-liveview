defmodule ArenaLiveview.Repo do
  use Ecto.Repo,
    otp_app: :arena_liveview,
    adapter: Ecto.Adapters.Postgres
end
