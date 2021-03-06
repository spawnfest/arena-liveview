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
    <div class="overlay" id="1" phx-hook="BroadcastMovement" data-user="<%= @user.uuid %>" data-users="<%= inspect @connected_users %>">
      <p <%= if @hide_info do "class=hide" end %> >
        <span class="blink">|> </span>
        Room: <span><b><%= @room.title %></b><span>
      </p>
      <p <%= if @hide_info do "class=hide" end %> > <span class="blink">|> </span>
        Live Users: <%= Enum.count(@connected_users) %>
      </p>
      <ul <%= if @hide_info do "class=hide" end %> >
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
      <div >
      <p>
        <span class="blink toggle-pipe <%= if @hide_info do 'down' end %>" phx-click="toggle_overlay"> |> </span>
         <%= if @hide_info do @room.title end %>
      </p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    with uuid <- UUID.uuid4(),
         :ok <- ConnectedUser.create_user_avatar(uuid),
         user <- ConnectedUser.create_connected_user(uuid, slug) do

      connected_users = ConnectedUser.list_connected_users(slug)
      other_connected_users = Enum.filter(connected_users, fn uuid -> uuid != user.uuid end)

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
          |> assign(:connected_users, IO.inspect other_connected_users)
          |> assign_room(room)
          |> assign(:hide_info, false)
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

  @impl true
  def handle_event("toggle_overlay", _params, socket) do
    {:noreply, assign(socket, :hide_info, !socket.assigns.hide_info)}
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

    handle_video_tracker_activity(slug, presence, payload)

    {:noreply,
     socket
     |> assign(:connected_users, presence)
     |> push_event("presence-changed", %{
       presence_diff: payload,
       presence: presence,
       uuid: user.uuid
     })}
  end

  defp handle_video_tracker_activity(slug, presence, %{leaves: leaves}) do
    room = Organizer.get_room(slug)
    video_tracker = room.video_tracker

    case video_tracker in leaves do
      false -> nil
      case presence do
        [] -> nil
        presences ->
          first_presence = hd presences
          IO.inspect "::: First Presence :::"
          IO.inspect video_tracker
          Organizer.update_room(room, %{video_tracker: first_presence})
      end
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
