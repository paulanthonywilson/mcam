defmodule Configure.Persist do
  @moduledoc """
  Persist and broadcast changes to settings.
  """
  use GenServer

  alias Configure.Events

  require Logger

  keys = [:filename, :update_topic, :settings]
  @enforce_keys keys
  defstruct keys

  @default_settings %{
    camera_awb_mode: :auto,
    camera_rotation: 0,
    camera_size: {644, 484},
    camera_img_effect: :none,
    email: nil
  }

  @setting_keys Map.keys(@default_settings)

  @type t :: %__MODULE__{
          filename: String.t(),
          update_topic: String.t(),
          settings: map()
        }

  def start_link({_filename, _update_topic, name} = args) do
    opts =
      if name do
        [name: name]
      else
        []
      end

    GenServer.start_link(__MODULE__, args, opts)
  end

  def init({filename, update_topic, _}) do
    {:ok,
     %__MODULE__{
       filename: filename,
       update_topic: update_topic,
       settings: read_settings(filename)
     }}
  end

  def keys do
    @setting_keys
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def set(server, key, value) do
    GenServer.cast(server, {:set, key, value})
  end

  def handle_call({:get, key}, _, %{settings: settings} = state) do
    {:reply, Map.get(settings, key), state}
  end

  def handle_cast(
        {:set, key, value},
        %{filename: filename, settings: settings, update_topic: update_topic} = state
      ) do
    Events.broadcast(update_topic, {:updated_config, key, value})
    updated_settings = %{settings | key => value}
    File.write(filename, :erlang.term_to_binary(updated_settings))
    {:noreply, %{state | settings: updated_settings}}
  end

  defp read_settings(file) do
    with {:ok, binary} <- File.read(file),
         %{} = settings <- decode_file_contents(binary) do
      Map.merge(default_settings(), settings)
    else
      {:error, :enoent} ->
        # Not been set - it's fine
        default_settings()

      other ->
        Logger.error("Unexpected problem reading configure settings file: #{inspect(other)}")
        default_settings()
    end
  end

  defp default_settings do
    @default_settings
  end

  defp decode_file_contents(binary) do
    try do
      :erlang.binary_to_term(binary)
    rescue
      ArgumentError ->
        "Corrupt file"
    end
  end
end
