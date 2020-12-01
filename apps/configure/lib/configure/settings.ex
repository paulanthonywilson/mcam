defmodule Configure.Settings do
  @moduledoc """
  Behaviour for holding settings. Also holds the default.
  """

  @default_settings %{
    camera_awb_mode: :auto,
    camera_exposure_mode: :auto,
    camera_rotation: 0,
    camera_size: {644, 484},
    camera_img_effect: :none,
    email: nil,
    registration_token: nil
  }

  @setting_keys Map.keys(@default_settings)

  @type key :: atom()
  @type value :: term()
  @type server :: atom() | pid()

  def keys, do: @setting_keys

  def default_settings, do: @default_settings

  @doc """
  A map with all the settings
  """
  @callback all_settings(server()) :: map()

  @doc """
  Set a value
  """
  @callback set(server(), key(), value()) :: :ok

  @doc """
  Get a value
  """
  @callback get(server(), key()) :: value()
end
