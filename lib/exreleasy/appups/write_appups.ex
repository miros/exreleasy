defmodule Exreleasy.Appups.WriteAppups do

  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Manifests.Storage
  alias Exreleasy.Appups.Appup

  @spec run(Path.t, Path.t) :: :ok | :no_return
  def run(old_manifest_path, new_manifest_path) do
    with {:ok, old_manifest} <- Storage.load(old_manifest_path),
         {:ok, new_manifest} <- Storage.load(new_manifest_path) do

      for app_name <- common_apps(old_manifest, new_manifest),
        do: write_appup(app_name, old_manifest.apps[app_name], new_manifest.apps[app_name])

      :ok
    else
      error -> throw(error)
    end
  end

  defp write_appup(app_name, old_app, new_app) do
    case Appup.make(old_app, new_app) do
      {:error, :unchanged} ->
        :ok
      {:ok, appup} ->
        app_name |> appup_path |> File.write!(:io_lib.format('~p', [appup]))
    end
  end

  defp common_apps(old_manifest, new_manifest) do
    old_set = Manifest.apps_set(old_manifest)
    new_set = Manifest.apps_set(new_manifest)

    MapSet.intersection(old_set, new_set) |> MapSet.to_list
  end

  defp appup_path(app_name) do
    "#{app_name}.appup.src"
  end

end
