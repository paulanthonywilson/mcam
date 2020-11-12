defmodule Camera.PicamSettings do
  @moduledoc """
  Set default settings
  """

  use GenServer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    send(self(), :set)
    {:ok, %{}}
  end

  def handle_info(:set, s) do
    Picam.set_size(644, 484)
    Picam.set_rotation(90)
    {:noreply, s}
  end
end
