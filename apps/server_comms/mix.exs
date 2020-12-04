defmodule ServerComms.MixProject do
  use Mix.Project

  def project do
    [
      app: :server_comms,
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
      mod: {ServerComms.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7"},
      {:configure, in_umbrella: true},
      {:camera, in_umbrella: true},
      {:jason, "~> 1.2"},
      # {:websocket_client, path: "~/dev/elixir-opensource/websocket_client"},
      # {:websocket_client, git: "git@github.com:paulanthonywilson/websocket_client.git"},
      {:websocket_client, github: "paulanthonywilson/websocket_client"},

      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
