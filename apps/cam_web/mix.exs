defmodule CamWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :cam_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CamWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.6"},
      {:phoenix_live_view, "~> 0.14.6"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:configure, in_umbrella: true},
      {:image_server, in_umbrella: true},
      {:server_comms, in_umbrella: true},
      {:phoenix_ecto, "~> 4.2"}
    ] ++ deps(Mix.target())
  end

  def deps(:host) do
    [
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end

  def deps(_), do: []

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ] ++ aliases(Mix.target())
  end

  defp aliases(:host), do: []

  defp aliases(_) do
    [
      compile: ["compile", &digest/1]
    ]
  end

  def digest(_args) do
    # Get some very weird behaviour if we try to run this
    # as a straight alias or even with Mix.Task.run/x
    Mix.Shell.cmd("MIX_TARGET=host mix phx.digest", fn resp -> IO.puts("digest: " <> resp) end)
  end
end
