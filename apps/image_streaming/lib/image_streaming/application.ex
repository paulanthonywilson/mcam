defmodule ImageStreaming.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: nil, options: cowboy_options()}
    ]

    opts = [strategy: :one_for_one, name: ImageStreaming.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch_spec do
    [
      {:_,
       [
         {"/raw_ws/camera_interface/:token", ImageStreaming.CameraCommsWebsocket, %{}},
         {"/raw_ws/browser_interface/:token", ImageStreaming.ImagesToBrowserWebsocket, %{}}
       ]}
    ]
  end

  defp cowboy_options do
    :image_streaming
    |> Application.fetch_env!(:cowboy_options)
    |> Keyword.put(:dispatch, dispatch_spec())
    |> Keyword.put(:ref, __MODULE__)
  end
end
