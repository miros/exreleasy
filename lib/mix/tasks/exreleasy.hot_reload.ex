defmodule Mix.Tasks.Exreleasy.HotReload do
  use Mix.Task
  import Exreleasy.MixTask

  alias Exreleasy.Manifests.Storage, as: ManifestStorage
  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.HotReloader

  @moduledoc """
    Reloads given apps on running node

        mix exreleasy.hotreload --node your_app@some-host --cookie 12345 --new-path /path/to/your/new/build/ --apps=first_app,second_app --reload-configs
        mix exreleasy.hotreload --node your_app@some-host --cookie 12345 --new-path /path/to/your/new/build/ --apps=first_app,second_app --reload-configs --downgrade

  """

  @shortdoc "Creates appup files for applications"
  def run(args) do
    options = parse_cli(args, cli_description())

    start_distributed_erlang(options)

    case do_reload(options) do
      :ok ->
        say "Apps reloaded!"
      {:error, error} ->
        say "Error reloading apps: #{inspect(error)}"
    end
  end

  defp start_distributed_erlang(options) do
    Node.start(:hot_reload_client, distributed_mode_for(options[:node]))
    Node.set_cookie(Node.self, String.to_atom(options[:cookie]))
  end

  defp distributed_mode_for(node) do
    if fully_qualified?(node) do
      :longnames
    else
      :shortnames
    end
  end

  defp fully_qualified?(node) do
    Regex.match?(~r/\.[a-zA-Z0-9-]+\z/, to_string(node))
  end

  defp do_reload(options) do
    node = String.to_atom(options[:node])

    with {:ok, apps} <- apps_to_reload(options) do
      new_path = options[:new_project_path]

      if options[:downgrade] do
        HotReloader.downgrade(node, new_path, apps, options)
      else
        HotReloader.upgrade(node, new_path, apps, options)
      end
    end
  end

  defp apps_to_reload(options) do
    manifest_path = Path.join(options[:new_project_path], Manifest.in_release_path())
    with {:ok, manifest} <- ManifestStorage.load(manifest_path) do
      all_apps = for {app_name, %{version: app_version}} <- manifest.apps, do: {app_name, app_version}

      if options[:apps] do
        {:ok, filter_apps(all_apps, options)}
      else
        {:ok, all_apps}
      end
    end
  end

  defp filter_apps(apps, options) do
    apps_to_reload = Enum.map(options[:apps], &String.to_atom/1)
    apps |> Enum.filter(fn({app_name, _}) -> app_name in apps_to_reload end)
  end

  defp cli_description do
    [
      name: "exreleasy.hotreload",
      description: "Reloads given apps on running node",
      parse_double_dash: true,
      options: [
        node: [
          value_name: "NODE",
          long: "--node",
          help: "Node to run hot reload at",
          required: true
        ],
        cookie: [
          value_name: "COOKIE",
          long: "--cookie",
          help: "Cookie for connecting to remote node",
          required: true
        ],
        new_project_path: [
          value_name: "NEW_PROJECT_PATH",
          long: "--new-path",
          help: "Path to new project code",
          required: true
        ],
        apps: [
          value_name: "APPS",
          long: "--apps",
          help: "Applications to reload",
          parser: fn (str) -> {:ok, String.split(str, ",")} end,
          required: false
        ]
      ],
      flags: [
        reload_configs: [
          value_name: "RELOAD_CONFIGS",
          long: "--reload-configs",
          help: "Reload configs as well",
        ],
        downgrade: [
          value_name: "DOWNGRADE",
          long: "--downgrade",
          help: "Downgrade application",
          required: false
        ],
      ]
    ]
  end

end
