defmodule McamServer.Repo.Migrations.DefaultCameraName do
  use Ecto.Migration

  def up do
    McamServer.Repo.query!("UPDATE cameras SET name=board_id")
  end

  def down do
    # nope
  end
end
