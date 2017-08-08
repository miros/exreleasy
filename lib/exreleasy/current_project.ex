defmodule Exreleasy.CurrentProject do

  def ensure_loaded(app_name) do
    case Application.load(app_name) do
      :ok ->
        :ok
      {:error, {:already_loaded, _}} ->
        :ok
      {:error, error} ->
        {:error, error}
    end
  end

  @spec applications() :: [atom]
  def applications() do
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

  @spec dependencies() :: {:ok, [atom]} | {:error, term}
  def dependencies do
    with {:ok, deps} <- Mix.Project.config[:deps_path] |> File.ls() do
      {:ok, Enum.map(deps, &String.to_atom/1)}
    end
  end

  @spec dependencies_versions() :: {:ok, map} | {:error, term}
  def dependencies_versions() do
    with {:ok, deps} <- dependencies(),
      do: do_get_deps_versions(deps, %{})
  end

  defp do_get_deps_versions([], versions), do: {:ok, versions}
  defp do_get_deps_versions([dep_name|other_deps], versions) do
    with :ok <- ensure_loaded(dep_name),
         {:ok, vsn} <- :application.get_key(dep_name, :vsn)
    do
      versions = Map.put(versions, dep_name, to_string(vsn))
      do_get_deps_versions(other_deps, versions)
    else
      {:error, error} -> {:error, {dep_name, "can not get version", error}}
    end
  end

end
