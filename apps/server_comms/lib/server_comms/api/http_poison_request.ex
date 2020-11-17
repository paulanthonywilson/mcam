defmodule ServerComms.Api.HttpPoisonRequest do
  @moduledoc """
  Delegates through to HTTPoison
  """

  @behaviour ServerComms.Api.Request

  @impl true
  defdelegate post(url, body \\ [], headers \\ [], options \\ []), to: HTTPoison
end
