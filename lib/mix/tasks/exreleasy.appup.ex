defmodule Mix.Tasks.Exreleasy.Appup do
  use Mix.Task
  import Exreleasy.MixTask

  @moduledoc """
    Creates appup files for upgrade from old manifest to new manifest

        mix exreleasy.appup /path/to/your/old/manifest.json /path/to/your/new/manifest.json
  """

  @shortdoc "Creates appup files for applications"
  def run([old_manifest_path, new_manifest_path]) do
    Exreleasy.Appups.WriteAppups.run(old_manifest_path, new_manifest_path)
    say "Appup files created"
  end

end
