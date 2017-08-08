defmodule Exreleasy.Appups.Appup do

  alias Exreleasy.Manifests.App
  alias Exreleasy.Release

  @spec in_release_path() :: Path.t
  def in_release_path() do
    Path.join(Release.dir(), "appups")
  end

  @spec make(App.t, App.t) :: term
  def make(old_app, new_app) do
    instructions = modules_to_reload(old_app.modules, new_app.modules) ++
      modules_to_remove(old_app.modules, new_app.modules)

    case instructions do
      [] ->
        {:error, :unchanged}
      [_|_] ->
        {:ok, {to_charlist(new_app.version), [{to_charlist(old_app.version), instructions}], []}}
    end
  end

  defp modules_to_reload(old_modules, new_modules) do
    new_modules
    |> Enum.map(&(load_or_update(&1, old_modules)))
    |> Enum.reject(&is_nil/1)
  end

  defp load_or_update({module, new_version}, old_modules) do
    case Map.get(old_modules, module) do
      nil ->
        {:load_module, module}
      old_version when new_version != old_version ->
        {:update, module, {:advanced, :ok}}
      _ -> nil
    end
  end

  defp modules_to_remove(old_modules, new_modules) do
    removed_modules = Map.keys(old_modules) -- Map.keys(new_modules)
    Enum.map(removed_modules, &({:delete_module, &1}))
  end

end
