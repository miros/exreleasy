defmodule Exreleasy.Appups.CreateAppup do

  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Manifests.Storage
  alias Exreleasy.Appups.Appup

  @spec run(map) :: :ok | no_return
  def run(%{old_release_path: old_release_path, new_release_path: new_release_path, appup_path: appup_path}) do
    with {:ok, old_manifest} <- Storage.load(old_release_path),
         {:ok, new_manifest} <- Storage.load(new_release_path),
         :ok <- check_deps(old_manifest.deps, new_manifest.deps) do
      full_appup_for(old_manifest, new_manifest) |> save(appup_path)
      :ok
    else
      error -> throw(error)
    end
  end

  defp check_deps(deps, deps), do: :ok
  defp check_deps(old_deps, new_deps),
    do: {:error, "dependencies changed old:#{inspect(old_deps)} new:#{inspect(new_deps)}"}

  defp full_appup_for(old_manifest, new_manifest) do
    for app_name <- common_apps(old_manifest, new_manifest), do:
      make_appup(app_name, old_manifest.apps[app_name], new_manifest.apps[app_name])
  end

  defp make_appup(app_name, old_app, new_app) do
    case Appup.make(old_app, new_app) do
      {:error, :unchanged} ->
        {app_name, []}
      {:ok, appup} ->
        {app_name, appup}
    end
  end

  defp save(appup, dest) do
    File.write!(dest, :io_lib.format('~p.\n', [appup]))
  end

  defp common_apps(old_manifest, new_manifest) do
    old_set = Manifest.apps_set(old_manifest)
    new_set = Manifest.apps_set(new_manifest)

    MapSet.intersection(old_set, new_set) |> MapSet.to_list
  end

end
