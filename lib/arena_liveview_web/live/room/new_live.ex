defmodule ArenaLiveviewWeb.Room.NewLive do
  use ArenaLiveviewWeb, :live_view

  alias ArenaLiveview.Organizer
  alias ArenaLiveview.Organizer.Room

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Organizer.subscribe()
      :timer.send_interval(1000, self(), :reload_room_list)
    end

    public_rooms = Organizer.list_rooms_by_privacy(false)
    viewers_quantity = for room <- public_rooms, do: {String.to_atom(room.title), Organizer.viewers_quantity(room)}

    socket =
      socket
      |> assign(:public_rooms, public_rooms)
      |> assign(:viewers_quantity, viewers_quantity)
      |> put_changeset()


    {:ok, socket}
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

  @impl true
  def handle_info(:reload_room_list, socket) do
    socket =
      update(
        socket,
        :viewers_quantity,
        fn _viewers_quantity -> for room <- socket.assigns.public_rooms, do: {String.to_atom(room.title), Organizer.viewers_quantity(room)} end
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

  defp put_changeset(socket, params \\ %{}) do
    socket
    |> assign(:changeset, Room.changeset(%Room{}, params))
  end
end
