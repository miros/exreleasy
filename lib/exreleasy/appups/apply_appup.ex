defmodule Exreleasy.Appups.ApplyAppup do

  alias Exreleasy.Release
  alias Exreleasy.Appups.Appup
  alias Exreleasy.Appups.Storage

  @spec run(map) :: :ok | no_return
  def run(%{release_path: release_path, appup_path: appup_path}) do
    with {:ok, files} <- file_list_for(appup_path),
         :ok <- Release.modify(release_path, files) do
      :ok
    else
      error -> throw(error)
    end
  end

  def file_list_for(appup_path) do
    with {:ok, release_appup} <- Storage.load(appup_path) do
      full_appup = {Appup.in_release_path(), File.read!(appup_path)}
      appup_files = for {app_name, appup} <- release_appup, do: {apppup_path(app_name), serialize(appup)}
      {:ok, [full_appup|appup_files]}
    end
  end

  def apppup_path(app_name) do
    "_build/#{Mix.env}/lib/#{app_name}/ebin/#{app_name}.appup"
  end

  def serialize(term), do: :io_lib.format("~p.\n", [term]) |> IO.iodata_to_binary()

end
