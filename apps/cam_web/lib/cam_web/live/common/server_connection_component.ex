defmodule CamWeb.ServerConnectionComponent do
  @moduledoc """
  Shows the status of the connection to the server.
  """
  use CamWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="row server-connection-component">
      <div class="column column-20"> Server connection status:</div>
      <div class="column column-20 status status-<%=@server_connection_status%>"><%= @server_connection_status %></div>
      <div class="column"></div>
    </div>
    """
  end
end
