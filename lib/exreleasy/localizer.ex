defmodule Exreleasy.Localizer do

  alias Exreleasy.Sys

  @elixir_apps [:elixir, :mix, :eex, :iex, :logger]
  @elixir_binaries ~w{mix iex}

  def run(dest) do
    File.mkdir_p(dest)
    copy_erlang(path(dest, "erlang"))
    copy_apps(@elixir_apps, path(dest, "elixir"))
    copy_binaries(@elixir_binaries, path(dest, "elixir/bin"))
    install_mix(path(dest, ".mix"))
    create_binstubs(path(dest, "binstubs"))
  end

  defp copy_erlang(dest) do
    Sys.copy_path(:code.root_dir, dest)
  end

  defp copy_apps(app_names, dest) do
    File.mkdir_p!(dest)
    for app <- app_names, do: copy_app(app, dest)
  end

  defp copy_app(app_name, dest) do
    app_path = app_name
      |> Application.app_dir
      |> Path.expand

    Sys.copy_path(app_path, Path.join(dest, to_string(app_name)))
  end

  defp copy_binaries(binary_names, dest) do
    File.mkdir_p!(dest)
    for binary_name <- binary_names, do: copy_binary(binary_name, dest)
  end

  defp copy_binary(binary_name, dest_dir) do
    source_path = Sys.which(binary_name)
    dest_path = Path.join(dest_dir, to_string(binary_name))
    Sys.copy_file(source_path, dest_path)
    File.chmod!(dest_path, 0o755)
  end

  defp install_mix(dest) do
    Sys.with_env %{"MIX_HOME" => dest}, fn ->
      Mix.Task.run("local.hex", ["--force"])
      Mix.Task.run("local.rebar", ["--force"])
    end
  end

  defp create_binstubs(dest) do
    File.mkdir_p!(dest)

    assets_path = Sys.asset_path(~w{binstubs})
    for file <- File.ls!(assets_path), do: Sys.copy_path(Path.join(assets_path, file), Path.join(dest, file))
  end

  defp path(release_path, name) do
    Path.join([release_path, name])
  end

end
