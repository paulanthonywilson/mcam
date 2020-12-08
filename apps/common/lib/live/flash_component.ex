defmodule Common.Live.FlashComponent do
  @moduledoc """
  Template for a flash display component.
  useage

  ```
  defmodule MyWebApp.MyFlashComponent do
    use Common.Live.FlashComponent, MyWebApp
  end
  ```

  In render

  ```
   <%= live_component @socket, CamWeb.FlashComponent, flash: @flash, clear_target: @myself %>
  ```
  """

  defmacro __using__(web_module) do
    quote do
      use unquote(web_module), :live_component

      def render(var!(assigns)) do
        ~L"""
        <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        <%= if assigns[:clear_target], do: "phx-target=#{@clear_target}" %>
        phx-value-key="info"><%= live_flash(@flash, :info) %></p>

        <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        <%= if assigns[:clear_target], do: "phx-target=#{@clear_target}" %>
        phx-value-key="error"><%= live_flash(@flash, :error) %></p>
        """
      end
    end
  end
end
