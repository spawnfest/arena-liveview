defmodule ArenaLiveviewWeb.Room.NewLive do
  use ArenaLiveviewWeb, :live_view

  alias ArenaLiveview.Organizer
  alias ArenaLiveview.Organizer.Room

  @impl true
  def mount(_params, _session, socket) do
    Organizer.subscribe()
    public_rooms = for room <- Organizer.list_rooms_by_privacy(false), do: {room, Organizer.viewers_quantity(room)}

    {:ok,
      socket
      |> assign(:public_rooms, public_rooms)
      |> put_changeset()
    }
  end

  @impl true
  def handle_info({:room_created, room}, socket) do
    socket =
      update(
        socket,
        :public_rooms,
        fn public_rooms -> [{room, Organizer.viewers_quantity(room)} | public_rooms] end
      )

    {:noreply, socket}
  end

  def handle_info({:enter_room, room}, socket) do
    socket =
      update(
        socket,
        :public_rooms,
        fn public_rooms -> [{room, Organizer.viewers_quantity(room)} | public_rooms] end
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    {:noreply,
      socket
      |> put_changeset(room_params)
    }
  end

  def handle_event("save", %{"room" => params}, socket) do
    case Organizer.create_room(params) do
      {:ok, room} ->
        {:noreply,
          socket
          |> push_redirect(to: Routes.show_path(socket, :show, room.slug))
        }
      {:error, changeset} ->
        {:noreply,
          socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, "Could not save the room.")
        }
    end
  end

  def handle_event("reload-assistants", %{"slug" => slug}, socket) do
    room = Organizer.get_room(slug)
    Organizer.broadcast(:enter_room, room)
    {:noreply, socket}
  end

  defp put_changeset(socket, params \\ %{}) do
    socket
    |> assign(:changeset, Room.changeset(%Room{}, params))
  end

end
