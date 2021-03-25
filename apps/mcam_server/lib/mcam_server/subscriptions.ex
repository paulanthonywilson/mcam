defmodule McamServer.Subscriptions do
  @moduledoc """
  Models subscriptions for users. Initially limits the number of cameras a user can have registered.

  """

  alias McamServer.Accounts.User
  alias McamServer.Repo
  alias McamServer.Subscriptions.Subscription

  import Ecto.Query

  def camera_quota(%User{id: user_id}) do
    user_id
    |> get_subscription()
    |> do_camera_quota()
  end

  defp do_camera_quota(nil) do
    {:none, 0}
  end

  defp do_camera_quota(%{reference: reference, camera_quota: camera_quota}) do
    {String.to_atom(reference), camera_quota}
  end

  defp get_subscription(user_id) do
    Repo.one(from s in Subscription, where: s.user_id == ^user_id)
  end

  def set_subscription(%User{id: user_id}, :alpha) do
    case %Subscription{}
         |> Subscription.changeset(%{user_id: user_id, camera_quota: 2, reference: "alpha"})
         |> Repo.insert() do
      {:ok, _subscription} ->
        :ok

      {:error, _} ->
        user_id
        |> get_subscription()
        |> Subscription.changeset(%{reference: "alpha", camera_quota: 2})
        |> Repo.update!()
    end
  end
end
