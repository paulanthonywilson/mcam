defmodule McamServer.Mailing.Mailer do
  @moduledoc """
  Sends the emails.
  """
  use Bamboo.Mailer, otp_app: :mcam_server

  @dialyzer {:nowarn_function, deliver_later: 1}

  import Bamboo.Email, only: [new_email: 1]

  def deliver(to, subject, body) do
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
end
