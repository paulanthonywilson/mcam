defmodule :migrate do
  def up, do: migrate(:up, all: true)
  def rollback, do: migrate(:down, step: 1)

  defp migrate(direction, opts) do
    {:ok, _} = Application.ensure_all_started(:mcam_server)
    path = Application.app_dir(:mcam_server, "priv/repo/migrations")
    Ecto.Migrator.run(McamServer.Repo, path, direction, opts)
    :init.stop()
  end
end
