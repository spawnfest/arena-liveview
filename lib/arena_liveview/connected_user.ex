defmodule ArenaLiveview.ConnectedUser do
  defstruct uuid: ""
  alias ArenaLiveview.ConnectedUser
  alias ArenaLiveviewWeb.Presence
  alias Identicon

  def create_connected_user(slug, me) do
    uuid = me
    Phoenix.PubSub.subscribe(ArenaLiveview.PubSub, "room:" <> slug)
    {:ok, _} = Presence.track(self(), "room:" <> slug, uuid, %{})
    %ConnectedUser{uuid: uuid}
  end

  def list_connected_users(slug) do
    Presence.list("room:" <> slug)
    # Check extra metadata needed from Presence
    |> Enum.map(fn {k, _} -> k end)
  end

  def broadcast_movement(slug, params) do
    Phoenix.PubSub.broadcast(ArenaLiveview.PubSub, "room:" <> slug, { :move, params })
  end

  def create_user_avatar(uuid) do
    # avatars_path = Path.join([:code.priv_dir(:arena_liveview) , "images/avatars"]);
    avatars_path = Path.absname("priv/static/images/avatars")
    Identicon.main(uuid, "#{avatars_path}/#{uuid}")
  end
end
