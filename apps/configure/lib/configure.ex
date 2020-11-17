defmodule Configure do
  @moduledoc """
  Interface to configuration settings.
  """
  use Configure.PersistKeyMethods

  defdelegate subscribe, to: Configure.Events
end
