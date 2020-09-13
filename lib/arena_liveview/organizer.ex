defmodule ArenaLiveview.Organizer do
  @moduledoc """
  The Organizer context.
  """

  import Ecto.Query, warn: false
  alias ArenaLiveview.Repo

  alias ArenaLiveview.Organizer.Room
  alias ArenaLiveviewWeb.Presence

  def list_present(slug) do
    Presence.list("room:" <> slug)
    # Check extra metadata needed from Presence
    |> Enum.map(fn {k, _} -> k end)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(ArenaLiveview.PubSub, "rooms")
  end

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Returns the list of public rooms.

  ## Examples

      iex> list_public_rooms()
      [%Room{}, ...]

  """
  def list_rooms_by_privacy(private) do
    from(room in Room, where: room.private == ^private)
    |> Repo.all()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  def get_room(slug) when is_binary(slug) do
    from(room in Room, where: room.slug == ^slug)
    |> Repo.one()
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    response = %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()

    case response do
      {:ok, room} ->
        broadcast(:room_created, room)
        response
      error -> error
    end
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def viewers_quantity(room) do
    list_present(room.slug) |> length()
  end

  def broadcast(event, room) do
    Phoenix.PubSub.broadcast(ArenaLiveview.PubSub, "rooms", {event, room})
  end

end
