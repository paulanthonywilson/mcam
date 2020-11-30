defmodule DirectImageSender.Application do
  @moduledoc """
  Wires up a cowboy endpoint specifically for receiving and sending the images
  through binary websockets.

  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: nil, options: cowboy_options()}
    ]

    opts = [strategy: :one_for_one, name: DirectImageSender.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def dispatch_spec do
    [
      {:_,
       [
         {"/raw_ws/images_receive", DirectImageSender.ImagesToBrowserWebsocketHandler, %{}}
       ]}
    ]
  end

  defp cowboy_options do
    :direct_image_sender
    |> Application.fetch_env!(:cowboy_options)
    |> Keyword.put(:dispatch, dispatch_spec())
  end
end
