defmodule ServerComms.Identification.BoardId do
  @moduledoc """
  Get a board id. Ideally tries to read the serial from `/proc/cpuinfo` but reverts to the hostname
  if that is not found.
  """

  def read_serial(filename \\ "/proc/cpuinfo") do
    with {:ok, contents} <- File.read(filename),
         {:ok, serial} <- extract_serial(contents) do
      {:ok, serial}
    else
      _ -> {:ok, hostname()}
    end
  end

  defp extract_serial(contents) do
    case Regex.named_captures(~r/^Serial\s*:\s*(?<serial>\w+)/m, contents) do
      %{"serial" => serial} ->
        {:ok, serial}

      err ->
        err
    end
  end

  defp hostname() do
    with {:ok, hostname} <- :inet.gethostname() do
      List.to_string(hostname)
    end
  end
end
