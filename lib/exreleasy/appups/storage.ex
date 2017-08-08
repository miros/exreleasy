defmodule Exreleasy.Appups.Storage do

  alias Exreleasy.Appups.Appup

  @spec apps_to_reload(Path.t) :: [atom]
  def apps_to_reload(release_path) do
    case Path.join(release_path, Appup.in_release_path) |> load() do
      {:ok, appups} ->
        for {app_name, _} <- appups, do: app_name
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
