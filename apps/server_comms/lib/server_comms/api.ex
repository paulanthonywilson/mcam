defmodule ServerComms.Api do
  @moduledoc """
  Api calls the the servercoms. Really just registration as everything
  else will be bone over websocket
  """
  @request (case Mix.env() do
              :test -> ServerComms.Api.MockRequest
              _ -> ServerComms.Api.HttpPoisonRequest
            end)
  alias ServerComms.Identification.BoardId

  @json_headers [{"Accept", "application/json"}, {"Content-Type", "application/json"}]
  require Logger

  @doc """
  Register with the registered email, password, and the board id. Really
  a testing seam for `register/2`
  """
  @spec register(String.t(), String.t(), String.t()) :: :ok | {:error, term()}
  def register(email, password, board_id) do
    request_json = Jason.encode!(%{email: email, password: password, board_id: board_id})

    case @request.post(register_url(), request_json, @json_headers, []) do
      {:ok, %{status_code: 200, body: token}} ->
        Configure.set_email(email)
        Configure.set_registration_token(token)
        Logger.info(fn -> "Registered to #{email}" end)
        :ok

      err ->
        Logger.info(fn -> "Failed registration: #{inspect(err)}" end)
        {:error, "registration failed"}
    end
  end

  @doc """
  See `Configure.register/2`
  """
  def register(email, password) do
    {:ok, board_id} = BoardId.read_serial()
    register(email, password, board_id)
  end

  defp register_url do
    :server_comms
    |> Application.fetch_env!(:server_url)
    |> Path.join("api/register_camera")
  end
end