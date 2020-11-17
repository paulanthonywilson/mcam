defmodule Camera.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Camera.Cam.impl(),
      Camera.PicamSettings
    ]

    opts = [strategy: :one_for_all, name: Camera.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
