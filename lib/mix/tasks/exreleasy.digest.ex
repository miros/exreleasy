defmodule Mix.Tasks.Exreleasy.Digest do
  use Mix.Task
  import Exreleasy.MixTask

  @moduledoc """
    Digests all project applications and writes manifest files into their ebin folders

        mix exreleasy.digest your_app_name
  """

  @shortdoc "Digests all project applications"
  def run(_) do
    Exreleasy.Manifests.WriteManifest.run()
    say "Manifests created"
  end

end
