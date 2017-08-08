defmodule Exreleasy.HotReloader do

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec reload(node, Path.t, [atom], map) :: :ok | {:error, term}
  def reload(node, new_project_path, apps, options) do
    GenServer.call({__MODULE__, node}, {:reload, new_project_path, apps, Map.new(options)})
  end

  def handle_call({:reload, new_project_path, apps, options}, _from, state) do
    reply = with :ok <- reload_apps(new_project_path, apps, options),
                 :ok <- reload_configs(new_project_path, options),
                 do: :ok

    {:reply, reply, state}
  end

  defp reload_apps(new_project_path, apps, options) do
    results = for name <- apps, do: {name, reload_app(new_project_path, name, options)}
    case Enum.filter(results, &match?({_, {:error, _}}, &1)) do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp reload_app(new_project_path, name, options) do
    reloader = options |> Map.get(:reloader, &default_reloader/2)
    path = new_project_path |> Path.join("_build/#{Mix.env}/lib/#{name}")
    reloader.(name, path)
  end

  defp reload_configs(new_project_path, %{reload_configs: true}),
    do: do_reload_configs(new_project_path)
  defp reload_configs(_new_project_path, _options),
    do: :ok

  defp do_reload_configs(new_project_path) do
    Path.join(new_project_path, "config/config.exs")
    |> Mix.Config.read!
    |> Mix.Config.persist
    :ok
  rescue
    exc -> {:error, exc}
  end

  defp default_reloader(app_name, new_path) do
    :release_handler.upgrade_app(app_name, to_charlist(new_path))
  end

end
