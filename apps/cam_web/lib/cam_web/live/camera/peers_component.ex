defmodule CamWeb.PeersComponent do
  @moduledoc """
  Lists the peers of this camera on the network and how to get to them.
  """
  use CamWeb, :live_component

  def render(%{peers: []} = assigns) do
    ~L"""
    """
  end

  def render(assigns) do
    ~L"""
      <h2>Peers</h2>
      <table class="mcam-peers">
        <thead>
          <th>Permanent access</th>
          <th>IP access</th>
        </thead>
        <tbody>
          <%= for {host, host_access, ip_access} <- @peers do %>
            <tr id=<%= host %>>
              <td><a href="<%= host_access %>" %><%= host_access %></a></td>
              <td><a href="<%= ip_access %>" %><%= ip_access %></a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    """
  end
end
