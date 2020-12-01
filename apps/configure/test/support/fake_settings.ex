defmodule Configure.FakeSettings do
  @moduledoc """
  Simple implementation of settings to get round the
  """

  @behaviour Configure.Settings

  alias Configure.Settings

  def all_settings(_) do
    Settings.default_settings()
  end

  def set(_, key, value) do
    send(self(), {:fake_setting_set, key, value})
    :ok
  end

  def get(_, key) do
    Settings.default_settings()[key]
  end
end
