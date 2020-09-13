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
      <div class="overlay" id="1" phx-hook="BroadcastMovement">
      <p>
        <span class="blink">|> </span>
        Room: <span><b><%= @room.title %></b><span>
      </p>
      <p> <span class="blink">|> </span>
        Live Users: <%= Enum.count(@connected_users) %>
      </p>
      <ul>
        <%= if @connected_users != [] do %>
          <%= for uuid <- @connected_users do %>
            <li><img src="<%= ArenaLiveviewWeb.Endpoint.static_url() %>/images/avatars/<%= uuid %>.png" alt="<%= uuid %> avatar" /></li>
          <% end %>
        <% else %>
          <div class="loader">Loading...</div>
        <% end %>
      </ul>
      <%= content_tag :div, id: 'video-player', 'phx-hook': "VideoPlaying", data: [video_id: @room.video_id, video_time: @room.video_time] do %>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    with uuid <- UUID.uuid4(),
         user <- ConnectedUser.create_connected_user(uuid, slug) do

      ConnectedUser.create_user_avatar(uuid)

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
  end

  # This event comes from .js and its being broadcasted to the room
  @impl true
  def handle_event("move", params, %{assigns: %{slug: slug}} = socket) do
    ConnectedUser.broadcast_movement(slug, params)
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

  # We get moves from every connected user and send them back to .js
  def handle_info({:move, params}, socket) do
    {:noreply,
     socket
     |> push_event("move", %{movement: params})}
  end

  @impl true
  def handle_info(
        %Broadcast{event: "presence_diff", payload: payload},
        %{assigns: %{slug: slug, user: user}} = socket
      ) do
    presence = ConnectedUser.list_connected_users(slug)

    {:noreply,
     socket
     |> assign(:connected_users, presence)
     |> push_event("presence-changed", %{
       presence_diff: payload,
       presence: presence,
       uuid: user.uuid
     })}
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
      _xs ->
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
