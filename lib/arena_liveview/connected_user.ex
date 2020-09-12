defmodule ArenaLiveview.ConnectedUser do
  defstruct uuid: ""
  alias ArenaLiveview.ConnectedUser
  alias ArenaLiveviewWeb.Presence

  def create_connected_user(slug, me) do
    uuid = me
    Phoenix.PubSub.subscribe(ArenaLiveview.PubSub, "room:" <> slug)
    {:ok, _} = Presence.track(self(), "room:" <> slug, uuid, %{})
    %ConnectedUser{uuid: uuid}
  end

  @spec list_connected_users(binary) :: [any]
  def list_connected_users(slug) do
    Presence.list("room:" <> slug)
    # Check extra metadata needed from Presence
    |> Enum.map(fn {k, _} -> k end)
  end

  def broadcast_movement(slug, params) do
    Phoenix.PubSub.broadcast(ArenaLiveview.PubSub, "room:" <> slug, { :move, params })
  end
end
