defmodule Configure.PersistKeyMethods do
  alias Configure.Persist

  defmacro __using__(_) do
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
  end
end
