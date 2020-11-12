defmodule ImageServer do
  @moduledoc false

  def receive_images_websocket_url do
    "ws://#{hostname()}.local:#{port()}/raw_ws/images_receive"
  end

  defp hostname do
    {:ok, name} = :inet.gethostname()
    List.to_string(name)
  end

  defp port do
    :image_server
    |> Application.fetch_env!(:cowboy_options)
    |> Keyword.fetch!(:port)
  end
end
