defmodule Configure.PersistKeyMethods do
  @moduledoc """
  Bit of macro automagic to create getter and setter functions for
  the persist fields.
  """
  alias Configure.Persist

  defmacro __using__(_) do
    kvp =
      for key <- Persist.keys() do
        quote do
          def unquote(key)() do
            Configure.Persist.get(:configuration, unquote(key))
          end

          def unquote(:"set_#{key}")(value) do
            Configure.Persist.set(:configuration, unquote(key), value)
          end
        end
      end

    [
      quote do
        def all_settings do
          Configure.Persist.all_settings(:configuration)
        end
      end
      | kvp
    ]
  end
end
