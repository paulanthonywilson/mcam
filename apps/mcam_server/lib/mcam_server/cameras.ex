defmodule McamServer.Cameras do
  @moduledoc """
  The Cameras context.
  """

  import Ecto.Query, warn: false

  alias McamServer.{Accounts, Repo}
  alias McamServer.Cameras.Camera
  alias Phoenix.PubSub

  @four_weeks 60 * 60 * 24 * 7 * 4
  @pubsub McamServer.PubSub

  @type token_target :: :camera | :browser

  defguard valid_token_target(destination) when destination in [:camera, :browser]

  @doc """
  Registers a camera to a a user
  """
  @spec register(Strint.t(), String.t(), String.t()) ::
          {:ok, Camera.t()} | {:error, :authentication_failure} | {:error, Ecto.Changeset.t()}
  def register(owner_email, owner_password, board_id) do
    case Accounts.get_user_by_email_and_password(owner_email, owner_password) do
      %{id: user_id} ->
        %Camera{owner_id: user_id}
        |> Camera.changeset(%{board_id: board_id})
        |> Repo.insert()
        |> maybe_broadcast_registration()
        |> maybe_retreive_original_if_duplicate({user_id, board_id})

      _ ->
        {:error, :authentication_failure}
    end
  end

  defp maybe_retreive_original_if_duplicate({:ok, _} = res, _), do: res

  defp maybe_retreive_original_if_duplicate(
         {:error, %{errors: errors}} = res,
         {owner_id, board_id}
       ) do
    case Keyword.get(errors, :owner_id) do
      {_, [constraint: :unique, constraint_name: "cameras_board_id_owner_id_index"]} ->
        {:ok,
         Repo.one!(from c in Camera, where: c.owner_id == ^owner_id and c.board_id == ^board_id)}

      _ ->
        res
    end
  end

  defp maybe_broadcast_registration({:ok, camera} = res) do
    PubSub.broadcast!(@pubsub, registration_topic(), {:camera_registration, camera})
    res
  end

  defp maybe_broadcast_registration(res), do: res

  @spec token_for(Camera.t() | integer(), token_target()) :: String.t()
  def token_for(%Camera{id: id}, token_target) do
    token_for(id, token_target)
  end

  def token_for(camera_id, token_target) when valid_token_target(token_target) do
    Plug.Crypto.encrypt(
      token_config(token_target, :secret),
      token_config(token_target, :salt),
      camera_id
    )
  end

  @spec from_token(String.t(), token_target()) ::
          {:ok, Camera.t()} | {:error, :expired | :invalid | :missing | :not_found}
  def from_token(token, token_target) when valid_token_target(token_target) do
    with {:ok, id} <-
           Plug.Crypto.decrypt(
             token_config(token_target, :secret),
             token_config(token_target, :salt),
             token,
             max_age: @four_weeks
           ),
         {_, camera} when not is_nil(camera) <- {:camera, Repo.get(Camera, id)} do
      {:ok, camera}
    else
      {:camera, nil} -> {:error, :not_found}
      err -> err
    end
  end

  @spec subscribe_to_camera(any) :: :ok
  def subscribe_to_camera(camera_id) do
    PubSub.subscribe(@pubsub, camera_topic(camera_id))
  end

  def broadcast_image(camera_id, image) do
    PubSub.broadcast!(@pubsub, camera_topic(camera_id), {:camera_image, camera_id, image})
  end

  @spec subscribe_to_registrations :: :ok | {:error, {:already_registered, pid}}
  def subscribe_to_registrations do
    PubSub.subscribe(@pubsub, registration_topic())
  end

  def user_cameras(%{id: user_id}) do
    user_cameras(user_id)
  end

  def user_cameras(user_id) do
    Repo.all(from c in Camera, where: c.owner_id == ^user_id)
  end

  defp camera_topic(camera_id), do: "camera:#{camera_id}"
  defp registration_topic, do: "camera_registrations"

  defp token_config(token_target, key) do
    token_target
    |> token_env()
    |> Keyword.fetch!(key)
  end

  defp token_env(:camera), do: Application.fetch_env!(:mcam_server, :camera_token)
end
