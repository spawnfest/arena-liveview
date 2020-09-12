defmodule ArenaLiveview.Repo.Migrations.RoomAddVideoTimeField do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :video_time, :float, default: 0.0
    end
  end
end
