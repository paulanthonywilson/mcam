defmodule Common do
  @moduledoc false

  @local_web_port 4000

  @doc """
  Given the hostname of a Nerves Mcam board, get the url that can be
  found through MDNS for directly connecting to the board on the local network.

  eg

  iex> Common.hostname_to_nerves_local_url("nerves-aax9")
  "http://nerves-aax9.local:4000"
  """
  @spec hostname_to_nerves_local_url(String.t()) :: String.t()
  def hostname_to_nerves_local_url(name), do: "http://#{name}.local:#{@local_web_port}"

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

  @doc """
  The web port on which the camera / board listens in the local network.
  """
  @spec local_web_port :: 4000
  def local_web_port, do: @local_web_port

  @doc """
  For tests that have some asynchronous parts. Wait until the funtion evaluates to the expected,
  sleeping for a millisecond between each waits. Attempts the funtion 100 times (by default).

  Returns the result of the last call to the function.
  """
  @spec wait_until_equals(any, (() -> any), any) :: any
  def wait_until_equals(expected, actual_fn, attempt_count \\ 100)
  def wait_until_equals(_expected, actual_fn, 0), do: actual_fn.()

  def wait_until_equals(expected, actual_fn, attempt_count) do
    case actual_fn.() do
      ^expected ->
        expected

      _ ->
        :timer.sleep(1)
        wait_until_equals(expected, actual_fn, attempt_count - 1)
    end
  end
end
