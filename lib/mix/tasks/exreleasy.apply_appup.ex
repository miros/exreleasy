defmodule Mix.Tasks.Exreleasy.ApplyAppup do
  use Mix.Task
  import Exreleasy.MixTask

  @moduledoc """
    Applies appup file to release

        mix exreleasy.apply_appup --release /path/to/your/release.tar.gz --appup /path/to/your/appup
        mix exreleasy.apply_appup --release /path/to/your/release/folder --appup /path/to/your/appup

  """

  @shortdoc "Applies appup file to release"
  def run(args) do
    options = parse_cli(args, cli_description())
    Exreleasy.Appups.ApplyAppup.run(options)
    say "Appup file applied"
  end

  defp cli_description do
    [
      name: "exreleasy.apply_appup",
      description: "Applies appup file to release",
      options: [
        release_path: [
          value_name: "RELEASE_PATH",
          long: "--release",
          help: "Path to release archive or folder",
          required: true
        ],
        appup_path: [
          value_name: "APPUP_PATH",
          long: "--appup",
          help: "Path to appup file",
          required: true
        ]
      ]
    ]
  end

end
