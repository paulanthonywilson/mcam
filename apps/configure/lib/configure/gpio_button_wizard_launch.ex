defmodule Configure.GpioButtonWizardLaunch do
  @moduledoc """
  Launches the wizard is the configured GPIO (default 17) is high for > 5 seconds.

  Based on https://github.com/nerves-networking/vintage_net_wizard/blob/e9199cad88842543602cdabc12148d509a336c2c/example/lib/wizard_example/button.ex


  """
  use GenServer
  require Logger
  alias Circuits.GPIO
  alias Configure.OwnHotspot

  @name __MODULE__
  @button_down_time 5_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def init(_) do
    {:ok, gpio} = GPIO.open(gpio_pin(), :input)
    :ok = GPIO.set_interrupts(gpio, :both)
    {:ok, %{pin: gpio_pin(), gpio: gpio}}
  end

  # Button down - ie voltage up
  def handle_info({:circuits_gpio, gpio_pin, _timestamp, 1}, %{pin: gpio_pin} = state) do
    Logger.info("Wizard launch button down")
    {:noreply, state, @button_down_time}
  end

  # Button up - ie voltage down
  def handle_info({:circuits_gpio, gpio_pin, _timestamp, 0}, %{pin: gpio_pin} = state) do
    Logger.info("Wizard launch button up")
    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    Logger.info("Launching wizard")
    :ok = OwnHotspot.start()
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug(fn -> "#{__MODULE__} - unknown message: #{inspect({msg, state})} " end)
    {:noreply, state}
  end

  defp gpio_pin, do: Application.fetch_env!(:configure, :wifi_wizard_gpio_pin)
end
