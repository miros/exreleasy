defmodule Exreleasy.Manifests.CreateManifest do

  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Manifests.Storage
  alias Exreleasy.CurrentProject

  @spec run(Path.t) :: :ok | no_return
  def run(manifest_path) do
    Mix.Task.run "loadpaths"
    with {:ok, manifest} <- CurrentProject.applications() |> Manifest.digest(),
         :ok <-  manifest_path |> Path.dirname |> File.mkdir_p(),
         :ok <- Storage.save(manifest_path, manifest) do
      :ok
    else
      error -> throw(error)
    end
  end

end
