defmodule ArenaLiveview.Repo.Migrations.RoomAddVideoTrackerField do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :video_tracker, :string
    end
  end
end
