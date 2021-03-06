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

    with {:ok, %{status_code: 200, body: body}} <-
           @request.post(register_url(), request_json, @json_headers, []),
         {:ok, token} <- Jason.decode(body) do
      Configure.set_email(email)
      Configure.set_registration_token(token)
      Logger.info(fn -> "Registered to #{email}" end)
      :ok
    else
      err ->
        Logger.info(fn -> "Failed registration: #{inspect(err)}" end)
        registration_error(err)
    end
  end

  defp registration_error({:ok, %{status_code: 401}}), do: {:error, :authentication}
  defp registration_error({:ok, %{status_code: 402}}), do: {:error, :quota_exceeded}
  defp registration_error(_), do: {:error, "registration failed"}

  @doc """
  See `Configure.register/2`
  """
  def register(email, password) do
    {:ok, board_id} = BoardId.read_serial()
    register(email, password, board_id)
  end

  defp register_url do
    :common
    |> Application.fetch_env!(:server_url)
    |> Path.join("api/register_camera")
  end

  @doc """
  Post the hostname and local ip to the server to record an unregistered camera.
  """
  def post_unregistered() do
    with {:ok, hostname} <- :inet.gethostname(),
         local_ip <- LedStatus.wlan0_address() do
      post_unregistered(hostname, local_ip)
    end
  end

  @doc false
  def post_unregistered(_hostname, nil), do: :ok

  def post_unregistered(hostname, local_ip) do
    hostname = List.to_string(hostname)
    local_ip = local_ip |> Tuple.to_list() |> Enum.join(".")
    request_json = Jason.encode!(%{"hostname" => hostname, "local_ip" => local_ip})

    case @request.post(unregistered_url(), request_json, @json_headers, []) do
      {:ok, %{status_code: 200}} ->
        :ok

      err ->
        Logger.info(fn -> "Failed to post as unregistered: #{inspect(err)}" end)
        err
    end
  end

  defp unregistered_url do
    :common
    |> Application.fetch_env!(:server_url)
    |> Path.join("api/unregistered_camera")
  end
end
