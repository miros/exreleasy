defmodule Exreleasy.Localizer do

  alias Exreleasy.Sys
  alias Exreleasy.MixTask

  @elixir_apps [:elixir, :mix, :eex, :iex, :logger]
  @elixir_binaries ~w{mix}

  def run(release_path) do
    File.mkdir_p!(release_path)

    run_steps release_path, [
      &copy_erlang/1,
      &copy_elixir/1,
      &copy_elixir_binaries/1,
      &install_mix/1,
      &create_binstubs/1
    ]
  end

  defp copy_erlang(release_path) do
    MixTask.say "Preparing erlang"

    dest = make_path(release_path, "erlang")
    Sys.copy_path(:code.root_dir, dest)
  end

  defp copy_elixir(release_path) do
    MixTask.say "Preparing elixir"

    dest = make_path(release_path, "elixir")
    for app <- @elixir_apps, do: copy_app(app, dest)
  end

  defp copy_app(app_name, dest) do
    app_path = app_name |> Application.app_dir |> Path.expand
    Sys.copy_path(app_path, Path.join(dest, to_string(app_name)))
  end

  defp copy_elixir_binaries(release_path) do
    MixTask.say "Preparing elixir binaries"

    dest = make_path(release_path, "elixir/bin")
    for binary_name <- @elixir_binaries, do: copy_system_binary(binary_name, dest)
  end

  defp copy_system_binary(binary_name, dest_dir) do
    source_path = Sys.which(binary_name)
    dest_path = Path.join(dest_dir, binary_name)
    Sys.copy_file(source_path, dest_path)
    Sys.chmod_as_executable(dest_path)
  end

  defp install_mix(release_path) do
    MixTask.say "Preparing mix tools"

    dest = make_path(release_path, ".mix")
    Sys.with_env %{"MIX_HOME" => dest}, fn ->
      Mix.Task.run("local.hex", ["--force"])
      Mix.Task.run("local.rebar", ["--force"])
    end
  end

  defp create_binstubs(release_path) do
    MixTask.say "Preparing binstubs"

    params = [erts_version: to_string(:erlang.system_info(:version))]
    for asset <- ~w{iex mix erl} do
      asset = "binstubs/#{asset}"
      dest = Path.join(release_path, asset)
      Sys.template_asset(asset, dest, params)
      Sys.chmod_as_executable(dest)
    end
  end

  defp make_path(release_path, name) do
    dest = Path.join([release_path, name])
    File.mkdir_p!(dest)
    dest
  end

  def run_steps(release_path, steps) do
    for step <- steps, do: step.(release_path)
  end

end
