defmodule Configure.Events do
  @moduledoc """
  Subscribing to, and broadcasting events
  """
  alias Phoenix.PubSub

  @update_topic "configuration_changed"
  @pubsub_name :configure_pubsub

  @spec pubsub_name :: atom()
  def pubsub_name, do: @pubsub_name

  def update_topic, do: @update_topic

  @spec subscribe(String.t()) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(topic \\ @update_topic) do
    PubSub.subscribe(pubsub_name(), topic)
  end

  def broadcast(topic, event) do
    PubSub.broadcast(pubsub_name(), topic, event)
  end
end
