defmodule ServerComms do
  @moduledoc false

  @doc """
  Register the camera with the server.
  """
  @spec register(String.t(), String.t()) :: :ok | {:error, term}
  defdelegate register(email, password), to: ServerComms.Api

  @doc """
  The status of the connection to the server.
  """
  @spec connection_status :: ServerComms.Ws.WebsocketConnector.connection_status()
  defdelegate connection_status, to: ServerComms.Ws.WebsocketConnector

  @doc """
  Subscribe to server status change updates
  """
  @spec subscribe :: :ok | {:error, {:already_registered, pid}}
  defdelegate subscribe, to: ServerComms.Events
end
