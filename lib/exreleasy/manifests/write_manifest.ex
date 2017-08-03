defmodule Exreleasy.Manifests.WriteManifest do

  alias Exreleasy.Release
  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Manifests.Storage

  @manifest_file "exreleasy.json"

  @spec run() :: :ok | :no_return
  def run() do
    with {:ok, manifest} <- current_applications() |> Manifest.digest(),
         :ok <- manifest_path() |> Path.dirname |> File.mkdir_p(),
         :ok <- Storage.save(manifest_path(), manifest) do
      :ok
    else
      error -> throw(error)
    end
  end

  defp manifest_path do
    Release.path |> Path.join(@manifest_file)
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
