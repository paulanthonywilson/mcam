defmodule Common do
  @moduledoc false

  @doc """
  Given the hostname of a Nerves Mcam board, get the url that can be
  found through MDNS for directly connecting to the board on the local network.

  eg

  iex> Common.hostname_to_nerves_local_url("nerves-aax9")
  "http://nerves-aax9.local:4000"
  """
  @spec hostname_to_nerves_local_url(String.t()) :: String.t()
  def hostname_to_nerves_local_url(name), do: "http://#{name}.local:4000"

  @doc """
  Uses `:inet.gethostname()` to get the hostname,
  and uses it as input to `hostname_to_nerves_local_url/1`.
  """
  @spec hostname_to_nerves_local_url() :: String.t()
  def hostname_to_nerves_local_url() do
    hostname_to_nerves_local_url(hostname())
  end

  @doc """
  Hostname (from `:inet.gethostname`) as a String
  """
  @spec hostname() :: String.t()
  def hostname do
    with {:ok, name} <- :inet.gethostname() do
      List.to_string(name)
    end
  end
end
