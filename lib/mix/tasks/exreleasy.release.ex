defmodule Mix.Tasks.Exreleasy.Release do
  use Mix.Task

  import Exreleasy.MixTask
  alias Exreleasy.Release

  @moduledoc """
    Creates archived release.

    Name of archive can be given as an option, otherwise current application version will be used.

        mix exreleasy.release
        mix exreleasy.release v0.0.1 # creates ./releases/archive/v0.0.1.tar.gz
  """

  @shortdoc "Releases current project"
  def run(args) do
    dest = Path.join([Release.archive_path, "#{release_name(args)}.tar.gz"])
    Release.make(dest)
    say "Project released, path: #{dest}"
  end

  defp release_name([]), do: Mix.Project.config[:version]
  defp release_name([name|_]), do: name

end
