defmodule Configure.Application do
  @moduledoc false

  use Application

  alias Configure.OwnHotspot

  @impl true
  def start(_type, _args) do
    children = [
      Configure.GpioButtonWizardLaunch,
      {Configure.Persist, {filename(), Configure.Events.update_topic(), :configuration}},
      {Phoenix.PubSub, name: Configure.Events.pubsub_name()}
    ]

    OwnHotspot.start_if_unconfigured()

    opts = [strategy: :one_for_one, name: Configure.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @filename (case(Mix.target()) do
               :host ->
                 Path.join(System.tmp_dir(), "mcam_#{Mix.env()}_setting")

               _ ->
                 "/root/mcam_settings"
             end)

  defp filename, do: @filename
end
