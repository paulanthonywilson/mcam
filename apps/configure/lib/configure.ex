defmodule Configure do
  @moduledoc """

  """

  defdelegate subscribe, to: Configure.Events
end
