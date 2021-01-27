defmodule Mcam.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: version(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test]}
    ]
  end

  defp releases do
    apps = [:common, :mcam_server, :mcam_server_web, :monitoring]
    [mcam: [applications: Enum.map(apps, &{&1, :permanent})]]
  end

  defp aliases do
    web_app_dir = "apps/mcam_server_web"
    asserts_dir = Path.join(web_app_dir, "assets")
    print_out = fn out -> IO.puts(out) end

    [
      release: [
        fn _ ->
          Mix.Shell.cmd("npm run deploy", [cd: asserts_dir], print_out)
          Mix.Shell.cmd("mix phx.digest", [cd: web_app_dir], print_out)
        end,
        "release"
      ]
    ]
  end

  defp version do
    "VERSION"
    |> File.read!()
    |> String.trim()
  end
end
