defmodule McamServerWeb.Camera.CameraRegistrationController do
  @moduledoc """
  Allows a camera to register with the server through a normal http (json) post. On reflection this is less complicated than
  pursuing registering through a websocket.
  """
  use McamServerWeb, :controller

  alias McamServer.Cameras

  require Logger

  def create(conn, %{"email" => email, "password" => password, "board_id" => board_id}) do
    conn = put_resp_header(conn, "content-type", "text/json")

    case Cameras.register(email, password, board_id) do
      {:ok, camera} ->
        conn
        |> put_status(200)
        |> json(Cameras.token_for(camera))

      {:error, :authentication_failure} ->
        conn
        |> put_status(401)
        |> json("nope")

      err ->
        Logger.error("Error registering camera: #{inspect(err)}")

        conn
        |> put_status(500)
        |> json("")
    end
  end

  def create(conn, params) do
    Logger.info(fn -> "Registration request without the required params: #{inspect(params)}" end)

    conn
    |> put_status(400)
    |> json("")
  end
end
