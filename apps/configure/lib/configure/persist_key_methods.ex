defmodule Configure.PersistKeyMethods do
  @moduledoc """
  Bit of macro automagic to create getter and setter functions for
  the persist fields.
  """
  alias Configure.Settings

  defmacro __using__(_) do
    settings_holder =
      case Mix.env() do
        :test -> Configure.FakeSettings
        _ -> Configure.Persist
      end

    kvp =
      for key <- Settings.keys() do
        quote do
          def unquote(key)() do
            unquote(settings_holder).get(:configuration, unquote(key))
          end

          def unquote(:"set_#{key}")(value) do
            unquote(settings_holder).set(:configuration, unquote(key), value)
          end
        end
      end

    [
      quote do
        def all_settings do
          unquote(settings_holder).all_settings(:configuration)
        end
      end
      | kvp
    ]
  end
end
