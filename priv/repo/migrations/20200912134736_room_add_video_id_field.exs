defmodule ArenaLiveview.Repo.Migrations.ToomAddVideoIdField do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :video_id, :text
    end
  end
end
