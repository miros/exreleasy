defmodule Mix.Tasks.Exreleasy.Digest do
  use Mix.Task

  import Exreleasy.MixTask
  alias Exreleasy.Release
  alias Exreleasy.Manifests.CreateManifest

  @moduledoc """
    Digests all project applications and creates release manifest

        mix exreleasy.digest your_app_name
  """
  @shortdoc "Creates release manifest"
  def run(_) do
    CreateManifest.run(Release.path())
    say "Manifest created"
  end

end
