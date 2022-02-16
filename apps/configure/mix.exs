defmodule Configure.MixProject do
  use Mix.Project

  def project do
    [
      app: :configure,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Configure.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_gpio, "~> 0.4.6"},
      {:phoenix_pubsub, "~> 2.0"}
    ] ++ deps(Mix.target())
  end

  defp deps(:host), do: []

  defp deps(_) do
    [
      # Fixed VintageNetWizard
      {:vintage_net_wizard,
       git: "git@github.com:paulanthonywilson/vintage_net_wizard.git",
       branch: "fix-configuration-amnesia-on-shutdown"}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
