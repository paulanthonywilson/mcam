defmodule Configure.Application do
  @moduledoc false

  use Application

  alias  Configure.WifiWizardInterface

  @impl true
  def start(_type, _args) do
    children = [
      Configure.GpioButtonWizardLaunch
    ]

    if should_start_wizard?() do
      WifiWizardInterface.start_wizard()
    end

    opts = [strategy: :one_for_one, name: Configure.Supervisor]
    Supervisor.start_link(children, opts)
  end


  def should_start_wizard? do
    with true <- function_exported?(VintageNet.Persistence, :call, 2),
         {:error, _} <- VintageNet.Persistence.call(:load, ["wlan0"]) do
      true
    else
      _ -> false
    end
  end
end
