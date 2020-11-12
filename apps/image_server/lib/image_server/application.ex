defmodule ImageServer.Application do
  @moduledoc """
  Wires up a cowboy endpoint specifically for receiving and sending the images
  through binary websockets.

  """

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: nil, options: cowboy_options()}
    ]

    opts = [strategy: :one_for_one, name: ImageServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def dispatch_spec do
    [
      {:_,
       [
         {"/raw_ws/images_receive", ImageServer.ImagesToBrowserWebsocketHandler, %{}}
         #  {"/raw_ws/images_send", ImageServer.ImagesFromCameraWebsocketHandler, %{}}
       ]}
    ]
  end

  defp cowboy_options do
    :image_server
    |> Application.fetch_env!(:cowboy_options)
    |> Keyword.put(:dispatch, dispatch_spec())
  end
end
