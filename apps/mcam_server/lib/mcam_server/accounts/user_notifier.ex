defmodule McamServer.Accounts.UserNotifier do
  @moduledoc """
  Sends through Bamboo mailer. Needs to be correctly configured.
  """
  use Bamboo.Mailer, otp_app: :mcam_server

  import Bamboo.Email, only: [new_email: 1]

  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, subject, body) do
    require Logger

    [from: from(), to: to, subject: subject, text_body: body]
    |> new_email()
    |> deliver_later()

    {:ok, %{to: to, body: body}}
  end

  def from do
    env = Application.fetch_env!(:mcam_server, __MODULE__)

    case env[:from] do
      nil ->
        "noreply@#{Keyword.fetch!(env, :domain)}"

      res ->
        res
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirm your email", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Password reset", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Confirm updated email", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
