defmodule Configure.OwnHotspot do
  @moduledoc """
  Runs the Wifi wizard, turning the board into a hot spot
  for the duration.
  """
  def start do
    VintageNetWizard.run_wizard()
  end
end
