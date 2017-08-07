defmodule Mix.Tasks.Exreleasy.CreateAppup do
  use Mix.Task

  import Exreleasy.MixTask
  alias Exreleasy.Appups.CreateAppup

  @moduledoc """
    Creates appup file

        mix exreleasy.create_appup --old-release /path/to/your/old/release.tar.gz --new-release /path/to/your/new/release.tar.gz
        mix exreleasy.create_appup --old-release /path/to/your/old/manifest.json --new-release /path/to/your/new/manifest.json

  """

  @shortdoc "Creates appup file for applications"
  def run(args) do
    options = parse_cli(args, cli_description())

    CreateAppup.run(options)

    say "Appup file created"
  end

  defp cli_description do
    [
      name: "exreleasy.create_appup",
      description: "Creates appup file",
      options: [
        old_release_path: [
          value_name: "OLD_RELEASE_PATH",
          long: "--old-release",
          help: "Path to old release archive or manifest file",
          required: true
        ],
        new_release_path: [
          value_name: "NEW_RELEASE_PATH",
          long: "--new-release",
          help: "Path to new release archive or manifest file",
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
