defmodule McamServerWeb.LiveViewHelpers do
  @moduledoc """
  Suggested https://hexdocs.pm/phoenix_live_view/0.14.8/security-model.html#content
  """
  import Phoenix.LiveView

  alias McamServer.Accounts
  alias McamServerWeb.Router.Helpers, as: Routes

  @spec assign_defaults(map, Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  def assign_defaults(%{"user_token" => token}, socket) do
    socket =
      assign_new(socket, :current_user, fn -> Accounts.get_user_by_session_token(token) end)

    if socket.assigns.current_user && socket.assigns.current_user.confirmed_at do
      socket
    else
      redirect(socket, to: Routes.user_session_path(McamServerWeb.Endpoint, :new))
    end
  end
end
