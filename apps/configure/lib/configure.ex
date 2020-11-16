defmodule Configure do
  @moduledoc """

  """
  use Configure.PersistKeyMethods

  defdelegate subscribe, to: Configure.Events
end
