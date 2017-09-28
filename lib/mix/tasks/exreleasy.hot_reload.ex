defmodule Mix.Tasks.Exreleasy.HotReload do
  use Mix.Task
  import Exreleasy.MixTask

  alias Exreleasy.Appups.Storage, as: AppupStorage


  @moduledoc """
    Reloads given apps on running node

        mix exreleasy.hotreload --node your_app@some-host --cookie 12345 --new-path /path/to/your/new/build/ --apps=first_app,second_app --reload-configs
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
    Node.start(:hot_reload_client, :shortnames)
    Node.set_cookie(Node.self, String.to_atom(options[:cookie]))
  end

  defp do_reload(options) do
    node = String.to_atom(options[:node])
    apps = apps_to_reload(options)

    Exreleasy.HotReloader.reload(node, options[:new_project_path], apps,
      reload_configs: options[:reload_configs])
  end

  defp apps_to_reload(options) do
    if options[:apps] do
      Enum.map(options[:apps], &String.to_atom/1)
    else
      AppupStorage.apps_to_reload(options[:new_project_path])
    end
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
        ],
      ],
      flags: [
        reload_configs: [
          value_name: "RELOAD_CONFIGS",
          long: "--reload-configs",
          help: "Reload configs as well",
        ]
      ]
    ]
  end

end
