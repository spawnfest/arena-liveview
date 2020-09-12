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
    <div class="overlay">
      <h2 id="1" phx-hook="BroadcastMovement"> Room: <span><b><%= @room.title %></b><span></h2>
      <h3>Connected Users: <%= Enum.count(@connected_users) %></h3>
      <ul>
        <%= for uuid <- @connected_users do %>
          <li><%= uuid %></li>
        <% end %>
      </ul>
      <%= content_tag :div, id: 'video-player', 'phx-hook': "VideoPlaying", data: [video_id: @room.video_id, video_time: @room.video_time] do %>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = ConnectedUser.create_connected_user()

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
          |> assign(:user, user)
          |> assign(:slug, slug)
          |> assign(:connected_users, [])
          |> assign_room(room)
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

  @impl true
  def handle_event("video-time-sync", current_time, socket) do
    slug = socket.assigns.room.slug
    room = Organizer.get_room(slug)
    current_user = socket.assigns.user.uuid

    case current_user == room.video_tracker do
      true ->
        {:ok, _updated_room} = Organizer.update_room(room, %{video_time: current_time})
        {:noreply, socket}
      false ->
        {:noreply, socket}
    end
  end

  defp assign_room(socket, room) do
    presences = list_present(socket)
    user = socket.assigns.user
    filtered_presences = Enum.filter(presences, fn uuid -> uuid != user.uuid end)

    case filtered_presences do
      [] ->
        {:ok, updated_room} = Organizer.update_room(room, %{video_time: 0, video_tracker: user.uuid})
        socket
        |> assign(:room, updated_room)
      [x|xs] ->
        socket
        |> assign(:room, room)
    end
  end

  defp list_present(socket) do
    Presence.list("room:" <> socket.assigns.slug)
    # Check extra metadata needed from Presence
    |> Enum.map(fn {k, _} -> k end)
  end
end
