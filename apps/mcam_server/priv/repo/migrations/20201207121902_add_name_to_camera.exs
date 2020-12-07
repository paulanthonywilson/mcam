defmodule McamServer.Repo.Migrations.AddNameToCamera do
  use Ecto.Migration

  def change do
    alter table(:cameras) do
      add :name, :string
    end
  end
end
