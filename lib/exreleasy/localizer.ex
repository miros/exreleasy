defmodule Exreleasy.Localizer do

  alias Exreleasy.Sys
  alias Exreleasy.MixTask

  @elixir_apps [:elixir, :mix, :eex, :iex, :logger]
  @elixir_binaries ~w{elixir mix}

  @spec run(String.t) :: :ok | no_return
  def run(release_path) do
    File.mkdir_p!(release_path)

    run_steps release_path, [
      &copy_erlang/1,
      &copy_elixir/1,
      &copy_elixir_binaries/1,
      &install_mix/1,
      &create_binstubs/1
    ]

    :ok
  end

  @spec copy_erlang(String.t) :: :ok | no_return
  defp copy_erlang(release_path) do
    MixTask.say "Preparing erlang"

    dest = make_path(release_path, "erlang")
    Sys.copy_path(to_string(:code.root_dir), dest)

    :ok
  end

  @spec copy_elixir(String.t) :: :ok | no_return
  defp copy_elixir(release_path) do
    MixTask.say "Preparing elixir"

    dest = release_path |> make_path("elixir") |> Path.join("lib")
    for app <- @elixir_apps, do: copy_app(app, dest)

    :ok
  end

  @spec copy_app(atom, String.t) :: :ok | no_return
  defp copy_app(app_name, dest) do
    app_path = app_name |> Application.app_dir |> Path.expand
    Sys.copy_path(app_path, Path.join(dest, to_string(app_name)))
    :ok
  end

  @spec copy_elixir_binaries(String.t) :: :ok | no_return
  defp copy_elixir_binaries(release_path) do
    MixTask.say "Preparing elixir binaries"

    dest = make_path(release_path, "elixir/bin")
    for binary_name <- @elixir_binaries, do: copy_system_binary(binary_name, dest)

    :ok
  end

  @spec copy_system_binary(String.t, String.t) :: :ok | no_return
  defp copy_system_binary(binary_name, dest_dir) do
    source_path = Sys.which(binary_name)
    dest_path = Path.join(dest_dir, binary_name)
    Sys.copy_file(source_path, dest_path)
    Sys.chmod_as_executable(dest_path)
    :ok
  end

  @spec install_mix(String.t) :: :ok | no_return
  defp install_mix(release_path) do
    MixTask.say "Preparing mix tools"

    dest = make_path(release_path, ".mix")
    Sys.with_env %{"MIX_HOME" => dest}, fn ->
      Mix.Task.run("local.hex", ["--force"])
      Mix.Task.run("local.rebar", ["--force"])
    end

    :ok
  end

  @spec create_binstubs(String.t) :: :ok | no_return
  defp create_binstubs(release_path) do
    MixTask.say "Preparing binstubs"

    params = [erts_version: to_string(:erlang.system_info(:version))]
    for asset <- ~w{iex mix iex_mix elixir erl} do
      asset = "binstubs/#{asset}"
      dest = Path.join(release_path, asset)
      Sys.template_asset(asset, dest, params)
      Sys.chmod_as_executable(dest)
    end

    :ok
  end

  @spec make_path(String.t, String.t) :: String.t | no_return
  defp make_path(release_path, name) do
    dest = Path.join([release_path, name])
    File.mkdir_p!(dest)
    dest
  end

  @spec run_steps(String.t, [fun]) :: :ok
  defp run_steps(release_path, steps) do
    for step <- steps, do: step.(release_path)
    :ok
  end

end
