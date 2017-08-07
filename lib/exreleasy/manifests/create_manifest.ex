defmodule Exreleasy.Manifests.CreateManifest do

  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Manifests.Storage

  @spec run(Path.t) :: :ok | no_return
  def run(release_path) do
    manifest_path = Path.join(release_path, Manifest.filename())

    with {:ok, manifest} <- current_applications() |> Manifest.digest(),
         :ok <-  manifest_path |> Path.dirname |> File.mkdir_p(),
         :ok <- Storage.save(manifest_path, manifest) do
      :ok
    else
      error -> throw(error)
    end
  end

  defp current_applications() do
    config = Mix.Project.config

    cond do
      Mix.Project.umbrella?(config) ->
        for %Mix.Dep{app: app} <- Mix.Dep.Umbrella.cached, do: app
      app = config[:app] ->
        [app]
      true ->
        []
    end
  end

end
