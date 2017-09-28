defmodule Exreleasy.Appups.Appup do

  alias Exreleasy.Manifests.App
  alias Exreleasy.Release

  @spec in_release_path() :: Path.t
  def in_release_path() do
    Path.join(Release.dir(), "appups")
  end

  @spec make(App.t, App.t) :: term
  def make(old_app, new_app) do
    old_modules = old_app.modules
    new_modules = new_app.modules

    up_instructions = update_instructions(old_modules, new_modules)
    down_instructions = update_instructions(new_modules, old_modules)

    case up_instructions do
      [] ->
        {:error, :unchanged}
      [_|_] ->
        {:ok, {to_charlist(new_app.version),
          [{to_charlist(old_app.version), up_instructions}],
          [{to_charlist(old_app.version), down_instructions}]
        }}
    end
  end

  defp update_instructions(old_modules, new_modules) do
    modules_to_reload(old_modules, new_modules) ++ modules_to_remove(old_modules, new_modules)
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
