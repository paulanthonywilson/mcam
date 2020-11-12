defmodule Camera.Cam do
  @moduledoc """
  Either the PiCam or a fake one
  """

  @callback next_frame() :: [byte]
  @callback child_spec(any()) :: map()

  @spec impl() :: Cam
  def impl(), do: Application.get_env(:camera, __MODULE__)
end
