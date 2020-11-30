defmodule Monitoring do
  @moduledoc """
  Currently does nothing.

  Has domain knowledge from everywhere though.
  """

  def camera_connected(_camera_id), do: :ok
  def camera_disconnected(_camera_id), do: :ok
  def image_received(_camera_id), do: nil
end
