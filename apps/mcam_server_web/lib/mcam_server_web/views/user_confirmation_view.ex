defmodule McamServerWeb.UserConfirmationView do
  use McamServerWeb, :view

  def user_email(%{assigns: assigns}) do
    case assigns[:current_user] do
      %{email: email} -> email
      _ -> ""
    end
  end
end
