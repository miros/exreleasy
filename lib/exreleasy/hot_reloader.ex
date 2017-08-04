defmodule Exreleasy.HotReloader do

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec reload(node, Path.t, [atom]) :: :ok | {:error, term}
  def reload(node, new_project_path, apps) do
    GenServer.call({__MODULE__, node}, {:reload, new_project_path, apps})
  end

  def handle_call({:reload, new_project_path, apps}, _from, state) do
    results = for name <- apps, do: {name, reload_app(new_project_path, name)}

    reply = case Enum.filter(results, &match?({_, {:error, _}}, &1)) do
      [] -> :ok
      errors -> {:error, errors}
    end

    {:reply, reply, state}
  end

  defp reload_app(new_project_path, name) do
    path = new_project_path |> Path.join("_build/#{Mix.env}/lib/#{name}")
    :release_handler.upgrade_app(name, to_charlist(path))
  end

end
