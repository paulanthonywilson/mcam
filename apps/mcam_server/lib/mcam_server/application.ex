defmodule McamServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      McamServer.Repo,
      {Phoenix.PubSub, name: McamServer.PubSub},
      McamServer.UnregisteredCameras.UnregisteredCameraEntrySupervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: McamServer.Supervisor)
  end
end
