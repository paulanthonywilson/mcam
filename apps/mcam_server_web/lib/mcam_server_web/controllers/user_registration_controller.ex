defmodule McamServerWeb.UserRegistrationController do
  use McamServerWeb, :controller

  alias McamServer.Accounts
  alias McamServer.Accounts.User
  alias McamServerWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def registration_confirmation(conn, _params) do
    render(conn, "registration_confirmation.html")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> put_flash(:info, "Registration successful")
        |> UserAuth.login_newly_registered_user(user)
        |> redirect(to: Routes.user_registration_path(conn, :registration_confirmation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
