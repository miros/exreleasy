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

  @spec dependencies_versions() :: {:ok, map} | {:error, term}
  def dependencies_versions() do
    deps = for {name, attrs} <- Mix.Dep.Lock.read,
      do: {name, elem(attrs, 2)}, into: %{}
    {:ok, deps}
  end

end
