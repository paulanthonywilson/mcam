defmodule ServerComms.Ws.WebsocketConnector do
  @moduledoc """
  Deals with connecting the websocket to the server. Takes a "let it die" approach
  to losing connections.
  """

  use GenServer

  alias ServerComms.Ws.WebsocketHandler

  require Logger

  @name __MODULE__

  @type connection_status :: :unregistered | :invalid_registration | :connected | :connecting

  @connection_delay 100
  @retry_connection_delay 5_000

  defstruct connection_status: :unregistered
  @type t :: %__MODULE__{connection_status: connection_status()}

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, %__MODULE__{}, {:continue, :attempt_connection}}
  end

  def handle_continue(:attempt_connection, state) do
    if Configure.registration_token() do
      start_connecting(@connection_delay, state)
    else
      {:noreply, state}
    end
  end

  def handle_info(:attempt_connection, %{connection_status: :connecting} = state) do
    case :websocket_client.start_link(ws_url(Configure.registration_token()), WebsocketHandler,
           parent: self()
         ) do
      {:ok, _pid} ->
        Logger.info("Connected to server")
        {:noreply, %{state | connection_status: :connected}}

      # unregister with 400 errors?
      err ->
        Logger.info(fn -> "Failed to connect to the server #{inspect(err)}" end)
        start_connecting(@retry_connection_delay, state)
    end
  end

  def handle_info(:websocket_terminated, state) do
    # Ok, let's just start again
    {:stop, :normal, state}
  end

  def handle_info(:attempt_connection, state), do: {:noreply, state}

  defp start_connecting(connect_after, state) do
    # Small delay in connecting to avoid thrashing and taking the application down in case
    # of websocket processed getting killed
    Process.send_after(self(), :attempt_connection, connect_after)
    {:noreply, %{state | connection_status: :connecting}}
  end

  defp ws_url(token) do
    :common
    |> Application.fetch_env!(:server_ws)
    |> Path.join("raw_ws/camera_interface")
    |> Path.join(to_string(token))
  end
end
