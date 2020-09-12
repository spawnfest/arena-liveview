defmodule ArenaLiveview.Repo.Migrations.AddPrivateField do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :private, :boolean, default: true
    end
  end
end
