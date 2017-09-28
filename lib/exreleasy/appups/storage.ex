defmodule Exreleasy.Appups.Storage do

  alias Exreleasy.Appups.Appup

  @spec app_versions(Path.t) :: [atom]
  def app_versions(release_path) do
    case Path.join(release_path, Appup.in_release_path) |> load() do
      {:ok, appups} ->
        for {app_name, {version, _}} <- appups, do: {app_name, version}
      {:error, _} -> []
    end
  end

  @spec load(Path.t) :: {:ok, term} | {:error, term}
  def load(appup_path) do
    case :file.consult(appup_path) do
      {:ok, [appups]} -> {:ok, appups}
      {:error, error} -> {:error, error}
    end
  end

end
