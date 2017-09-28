defmodule Mix.Tasks.Exreleasy.Digest do
  use Mix.Task

  import Exreleasy.MixTask
  # alias Exreleasy.Release
  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Manifests.CreateManifest

  @moduledoc """
    Digests all project applications and creates release manifest

        mix exreleasy.digest
  """
  @shortdoc "Creates release manifest"
  def run(args) do
    options = parse_cli(args, cli_description())

    manifest_path = options[:to] || Manifest.in_release_path()
    CreateManifest.run(manifest_path)

    say "Manifest created"
  end

  defp cli_description do
    [
      name: "exreleasy.digest",
      description: "Digests all project applications and creates release manifest",
      parse_double_dash: true,
      options: [
        to: [
          value_name: "MANIFEST_PATH",
          long: "--to",
          help: "Path to new manifest to be created",
          required: false
        ]
      ]
    ]
  end

end
