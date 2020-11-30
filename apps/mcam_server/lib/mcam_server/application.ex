defmodule McamServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      McamServer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: McamServer.PubSub}
      # Start a worker by calling: McamServer.Worker.start_link(arg)
      # {McamServer.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: McamServer.Supervisor)
  end
end
