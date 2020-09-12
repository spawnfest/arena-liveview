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
    IO.inspect(assigns, label: "assignsssss")
    ~L"""
    <div class="overlay">
      <h2 id="1" phx-hook="BroadcastMovement"> Room: <span><b><%= @room.title %></b><span></h2>
      <h3>Live Users: <%= Enum.count(@connected_users) %></h3>
      <ul>
        <%= for uuid <- @connected_users do %>
          <li><img src="<%= ArenaLiveviewWeb.Endpoint.static_url() %>/images/test.png" alt="<%= uuid %> avatar" /></li>
        <% end %>
      </ul>
      <%= content_tag :div, id: 'video-player', 'phx-hook': "VideoPlaying", data: [video_id: @room.video_id] do %>
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
          |> assign(:room, room)
          |> assign(:user, user)
          |> assign(:slug, slug)
          |> assign(:connected_users, [])
        }
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    presence = Organizer.list_present(socket.assigns.slug)

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
end
