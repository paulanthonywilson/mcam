defmodule ServerComms.Api.Request do
  @moduledoc """
  Strictly speaking this is a too low level seam for the api test. Blatantly mirrors
  HTTPoison. Implemented by HttPoisonRequest.
  """

  @doc """
  The only api call we need right now (for registering the camera), as everything else goes through the websocket.
  """
  @callback post(binary(), any(), HTTPoison.Base.headers(), Keyword.t()) ::
              {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
              | {:error, HTTPoison.Error.t()}
end
