defmodule Camera.FakeCam do
  @moduledoc """
  Returns alternate images of a jumping stick man
  """
  use GenServer
  @behaviour Camera.Cam

  @name __MODULE__

  defstruct images: nil, undisplayed_images: nil
  @type t :: %__MODULE__{images: list(String.t()), undisplayed_images: list(String.t())}

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  @impl true
  def init(_) do
    image_dir = Application.app_dir(:camera, "priv/fake_images")
    images = for f <- File.ls!(image_dir), do: File.read!(image_dir <> "/" <> f)
    {:ok, %__MODULE__{images: images, undisplayed_images: images}}
  end

  @impl true
  def next_frame() do
    GenServer.call(@name, :fake_image)
  end

  @spec stack_next_image([byte()]) :: :ok
  def stack_next_image(image) do
    GenServer.cast(@name, {:stack_next_image, image})
  end

  @impl true
  def handle_call(:fake_image, from, s) do
    Process.send_after(self(), {:fake_image, from}, 1_000)
    {:noreply, s}
  end

  @impl true
  def handle_info({:fake_image, from}, s = %{undisplayed_images: [image | []], images: images}) do
    GenServer.reply(from, image)
    {:noreply, %{s | undisplayed_images: images}}
  end

  def handle_info({:fake_image, from}, s = %{undisplayed_images: [image | rest]}) do
    GenServer.reply(from, image)
    {:noreply, %{s | undisplayed_images: rest}}
  end

  @impl true
  def handle_cast({:stack_next_image, image}, s = %{undisplayed_images: undisplayed_images}) do
    {:noreply, %{s | undisplayed_images: [image | undisplayed_images]}}
  end
end
