defmodule ArenaLiveviewWeb.Room.ShowLive do
  @moduledoc """
  A LiveView for creating and joining chat rooms.
  """
  use ArenaLiveviewWeb, :live_view
  alias ArenaLiveview.Organizer
  alias ArenaLiveview.ConnectedUser

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
        <%= for uuid <- @connected_users do %>
          <li><img src="<%= ArenaLiveviewWeb.Endpoint.static_url() %>/images/avatars/<%= uuid %>.png" alt="<%= uuid %> avatar" /></li>
        <% end %>
      </ul>
      <%= content_tag :div, id: 'video-player', 'phx-hook': "VideoPlaying", data: [video_id: @room.video_id] do %>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    uuid = socket.private.connect_params["me"]
    user = ConnectedUser.create_connected_user(slug, uuid)
    ConnectedUser.create_user_avatar(uuid)

    case Organizer.get_room(slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "That room does not exist.")
         |> push_redirect(to: Routes.new_path(socket, :new))}

      room ->
        {:ok,
         socket
         |> assign(:room, room)
         |> assign(:user, user)
         |> assign(:slug, slug)
         |> assign(:connected_users, [])}
    end
  end

  # This event comes from .js and its being broadcasted to the room
  @impl true
  def handle_event("move", params, %{assigns: %{slug: slug}} = socket) do
    ConnectedUser.broadcast_movement(slug, params)
    {:noreply, socket}
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
        %{assigns: %{slug: slug}} = socket
      ) do
    presence = ConnectedUser.list_connected_users(slug)

    {:noreply,
     socket
     |> assign(:connected_users, presence)
     |> push_event("presence-changed", %{presence_diff: payload, presence: presence})}
  end
end
