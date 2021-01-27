defmodule CamWeb.BinaryWs.DirectImageSocket do
  @moduledoc """
  Socket for "streaming" mjpeg from the camera to the locally connected browser.
  """
  @behaviour Phoenix.Socket.Transport
  require Logger

  def child_spec(_) do
    # Cargo culted from https://hexdocs.pm/phoenix/1.5.7/Phoenix.Socket.Transport.html
    # I think what's going on is that for _reasons_ the endpoint wants to start a process
    # so here's nil process.
    %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(_) do
    {:ok, %{}}
  end

  def init(state) do
    send(self(), :send_image)
    {:ok, state}
  end

  def handle_in(_, state) do
    # Not expecting any incoming messages
    {:ok, state}
  end

  def handle_info(:send_image, state) do
    image = Camera.next_frame()
    Process.send_after(self(), :send_image, 50)
    {:push, {:binary, image}, state}
  end

  def handle_info(message, state) do
    Logger.info(fn -> "Unexpected handle info message: #{inspect(message)}" end)
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
