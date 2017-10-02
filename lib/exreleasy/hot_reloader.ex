defmodule Exreleasy.HotReloader do

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec upgrade(node, Path.t, [keyword()], map) :: :ok | {:error, term}
  def upgrade(node, code_path, apps, options) do
    options = Map.new(options) |> Map.merge(%{reloader: &upgrade_app/2})
    GenServer.call({__MODULE__, node}, {:reload, code_path, apps, options})
  end

  @spec downgrade(node, Path.t, [keyword()], map) :: :ok | {:error, term}
  def downgrade(node, code_path, apps, options) do
    options = Map.new(options) |> Map.merge(%{reloader: &downgrade_app/2})
    GenServer.call({__MODULE__, node}, {:reload, code_path, apps, options})
  end

  @spec reload(node, Path.t, map, map) :: :ok | {:error, term}
  def reload(node, code_path, apps, options) do
    GenServer.call({__MODULE__, node}, {:reload, code_path, apps, Map.new(options)})
  end

  def handle_call({:reload, code_path, apps, options}, _from, state) do
    reloader = Map.fetch!(options, :reloader)
    reply = with :ok <- reload_apps(code_path, apps, reloader),
         :ok <- reload_configs(code_path, options),
         do: :ok
    {:reply, reply, state}
  end

  defp reload_apps(code_path, apps, reloader) do
    results = for {app_name, _} = app <- apps,
      do: {app_name, reload_app(code_path, app, reloader)}
    case Enum.filter(results, &match?({_, {:error, _}}, &1)) do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp reload_app(code_path, {app_name, _app_version} = app, reloader) do
    path = code_path |> Path.join("_build/#{Mix.env}/lib/#{app_name}")
    reloader.(app, path)
  end

  defp reload_configs(code_path, %{reload_configs: true}),
    do: do_reload_configs(code_path)
  defp reload_configs(_code_path, _options),
    do: :ok

  defp do_reload_configs(code_path) do
    Path.join(code_path, "config/config.exs")
    |> Mix.Config.read!
    |> Mix.Config.persist
    :ok
  rescue
    exc -> {:error, exc}
  end

  defp upgrade_app({app_name, _app_version}, new_path) do
    :release_handler.upgrade_app(app_name, to_charlist(new_path))
  end

  defp downgrade_app({app_name, app_version}, new_path) do
    :release_handler.downgrade_app(app_name, to_charlist(app_version), to_charlist(new_path))
  end

end
