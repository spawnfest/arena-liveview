defmodule ArenaLiveviewWeb.Room.ShowLive do
  @moduledoc """
  A LiveView for creating and joining chat rooms.
  """
  use ArenaLiveviewWeb, :live_view
  alias ArenaLiveview.Organizer
  alias ArenaLiveview.ConnectedUser

  alias ArenaLiveviewWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <h1 id="1" phx-hook="BroadcastMovement"><%= @room.title %></h1>
    <h3>Connected Users:</h3>
    <ul>
    <%= for uuid <- @connected_users do %>
      <li><%= uuid %></li>
    <% end %>
    </ul>
    <%= content_tag :div, id: 'video-player', 'phx-hook': "VideoPlaying", data: [video_id: @room.video_id] do %>
    <% end %>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = create_connected_user()

    Phoenix.PubSub.subscribe(ArenaLiveview.PubSub, "room:" <> slug)
    {:ok, _} = Presence.track(self(), "room:" <> slug, user.uuid, %{})

    case Organizer.get_room(slug) do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "That room does not exist.")
          |> push_redirect(to: Routes.new_path(socket, :new))
        }
      room ->
        {:ok,
          socket
          |> assign(:room, room)
          |> assign(:user, user)
          |> assign(:slug, slug)
          |> assign(:connected_users, [])
        }
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    presence = list_present(socket)

    {:noreply,
      socket
      |> assign(:connected_users, presence)
      |> push_event("presence-changed", %{presence: presence})
    }
  end

  @impl true
  def handle_event("publish-move", params, socket) do
    #
    IO.puts "getting stuff"
    IO.inspect params
    {:noreply, socket}
  end

  defp list_present(socket) do
    Presence.list("room:" <> socket.assigns.slug)
    # Check extra metadata needed from Presence
    |> Enum.map(fn {k, _} -> k end)
  end

  defp create_connected_user do
    # Very simple new user implementation
    %ConnectedUser{uuid: UUID.uuid4()}
  end
end
