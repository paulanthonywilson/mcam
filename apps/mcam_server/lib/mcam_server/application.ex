defmodule McamServer.Application do
  @moduledoc false

  use Application

  @unregistered_camera_registry_name :unregistered_camera_registry

  def start(_type, _args) do
    children = [
      McamServer.Repo,
      {Phoenix.PubSub, name: McamServer.PubSub},
      {Registry,
       keys: :duplicate,
       name: McamServer.UnregisteredCameras.UnregisteredCameraEvents.registry_name()},
      {Registry, keys: :unique, name: @unregistered_camera_registry_name},
      McamServer.UnregisteredCameras.UnregisteredCameraEntrySupervisor,
      {McamServer.UnregisteredCameras,
       name: McamServer.UnregisteredCameras, registry_name: @unregistered_camera_registry_name}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: McamServer.Supervisor)
  end
end
