defmodule ArenaLiveview.Organizer.Room do
  @moduledoc """
  Schema for creating video chat rooms.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :title, :string
    field :slug, :string
    field :private, :boolean, default: true
    field :video_id, :string
    field :video_time, :float, default: 0.0
    field :video_tracker, :string
    timestamps()
  end

  @fields [:title, :slug, :private, :video_id, :video_time, :video_tracker]

  def changeset(room, attrs) do
    room
    |> cast(attrs, @fields)
    |> validate_required([:title, :slug])
    |> format_slug()
    |> format_video_url()
    |> unique_constraint(:slug)
  end

  defp format_slug(%Ecto.Changeset{changes: %{slug: _}} = changeset) do
    changeset
    |> update_change(:slug, fn slug ->
      slug
      |> String.downcase()
      |> String.replace(" ", "-")
    end)
  end
  defp format_slug(changeset), do: changeset

  defp format_video_url(%Ecto.Changeset{changes: %{video_id: _}} = changeset) do
    changeset
    |> update_change(:video_id, fn video_url ->
      ~r{^.*(?:youtu\.be/|\w+/|v=)(?<id>[^#&?]*)}
      |> Regex.named_captures(video_url)
      |> get_in(["id"])
    end)
  end
  defp format_video_url(changeset), do: changeset
end
