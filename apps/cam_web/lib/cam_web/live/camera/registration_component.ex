defmodule CamWeb.RegistrationComponent do
  @moduledoc """
  Takes care of registering or re-registering with the server. Authenticates
  the user with their login credentials.
  """
  use CamWeb, :live_component

  alias CamWeb.RegistrationChangeset

  def update(assigns, socket) do
    registration_changeset =
      RegistrationChangeset.changeset_for(%{
        email: assigns[:email],
        password: ""
      })

    registered? = !is_nil(assigns[:registration_token])

    {:ok, assign(socket, registration: registration_changeset, registered?: registered?)}
  end

  def render(assigns) do
    ~L"""
    <h2>Registration</h2>
    <%= live_component @socket, CamWeb.FlashComponent, flash: @flash, clear_target: @myself %>
    <%= f = form_for(@registration, "#", as: :registration, phx_submit: "register", phx_target: @myself) %>

    <div class="field">
      <%= text_input f, :email,
                     placeholder: "email",
                     autocomplete: "off" %>
      <%= error_tag f, :email %>
    </div>
    <div class="field">
      <%= password_input f, :password,
                     placeholder: "password",
                     autocomplete: "off" %>
      <%= error_tag f, :password %>
    </div>
    <button type="submit"><%= registration_text(@registered?) %></button>
    </form>
    """
  end

  def handle_event("register", %{"registration" => registration}, socket) do
    changeset = RegistrationChangeset.insert_changeset_for(registration)

    socket =
      socket
      |> clear_flash()
      |> assign(registration: changeset)
      |> attempt_registration(registration, changeset)

    {:noreply, socket}
  end

  defp attempt_registration(
         socket,
         %{"email" => email, "password" => password},
         %{valid?: true}
       ) do
    case ServerComms.register(email, password) do
      :ok ->
        put_flash(socket, :info, "Registered")

        {:error, :authentication} ->
          put_flash(socket, :error, "Your username and/or password were not liked")
        {:error, :quota_exceeded} ->
          put_flash(socket, :error, "You have run out of your camera quota")
      _ ->
        put_flash(socket, :error, "Registration failed for unknown reasons")
    end
  end

  defp attempt_registration(socket, _, _) do
    socket
  end

  defp registration_text(true), do: "Re-register"
  defp registration_text(_), do: "Register"
end
