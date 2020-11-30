defmodule ImageStreaming.MixProject do
  use Mix.Project

  def project do
    [
      app: :image_streaming,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ImageStreaming.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, ">= 0.0.0"},
      {:cowboy, ">= 0.0.0"},
      {:plug_cowboy, ">= 0.0.0"},
      {:websocket_client, git: "git@github.com:jeremyong/websocket_client.git"},
      {:mcam_server, in_umbrella: true},
      {:monitoring, in_umbrella: true}
    ]
  end
end
