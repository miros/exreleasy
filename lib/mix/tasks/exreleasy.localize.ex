defmodule Mix.Tasks.Exreleasy.Localize do
  use Mix.Task

  import Exreleasy.MixTask
  alias Exreleasy.{Release, Localizer}

  @moduledoc """
    Localizes current project with local erlang runtime

    All files will be written to ./release dir

        mix exreleasy.localize
  """

  @shortdoc "Localizes current project with local erlang runtime"
  def run(_) do
    Localizer.run(Release.path)
    say "Project localized, path: #{Release.path}"
  end

end
