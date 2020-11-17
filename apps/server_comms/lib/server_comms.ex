defmodule ServerComms do
  @moduledoc false

  @doc """
  Register the camera with the server.
  """
  @spec register(String.t(), String.t()) :: :ok | {:error, term}
  defdelegate register(email, password), to: ServerComms.Api
end
