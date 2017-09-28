defmodule ExreleasyTest do
  use ExUnit.Case
  doctest Exreleasy

  alias Exreleasy.Sys
  alias Exreleasy.Release

  @elixir_image "exreleasy_test_elixir"
  @bare_image "exreleasy_test_bare"
  @release_path "test_app/release"

  setup_all do
    docker_build_image(@elixir_image, "test/Dockerfile.elixir")
    docker_build_image(@bare_image, "test/Dockerfile.bare")

    File.rm_rf!(@release_path)
    docker_run(@elixir_image, "mix deps.get && mix compile && mix exreleasy.release test_release")

    :ok
  end

  @tag timeout: 3 * 60 * 1000
  test "it successfully releases project" do
    assert MapSet.new(File.ls!(@release_path)) == MapSet.new(~w{erlang elixir .mix .hex binstubs archive exreleasy.json})
    assert_exists("archive/test_release.tar.gz")

    docker_run(@bare_image, ~s{./release/binstubs/mix run -e ":ok"})
    docker_run(@bare_image, ~s{./release/binstubs/elixir -e ":ok"})
    docker_run(@bare_image, ~s{./release/binstubs/iex -e "exit(0)"})
    docker_run(@bare_image, ~s{./release/binstubs/iex_mix run -e ":ok"})
  end

  @tag timeout: 3 * 60 * 1000
  test "it creates appup file for hot reload" do
    docker_run(@elixir_image, "mix exreleasy.create_appup \
      --old-release empty_manifest.json --new-release release/archive/test_release.tar.gz --appup release/appups")

    assert_exists("appups")

    docker_run(@elixir_image, "mix exreleasy.apply_appup \
      --release release/archive/test_release.tar.gz --appup release/appups")

    release_path = Path.join(@release_path, "archive/test_release.tar.gz")

    {:ok, new_appups_data} = Release.read_file(release_path, "release/appups")
    assert String.contains?(new_appups_data, ~s|[{"0.1.0",[{load_module,'Elixir.TestApp'}]}]|)
    assert String.starts_with?(new_appups_data, "[{test_app,")

    {:ok, new_appup_data} = Release.read_file(release_path, "_build/dev/lib/test_app/ebin/test_app.appup")
    assert String.contains?(new_appup_data, ~s|[{"0.1.0",[{load_module,'Elixir.TestApp'}]}]|)
    assert String.starts_with?(new_appup_data, ~s|{"0.1.0",|)

    File.rm(Path.join(@release_path, "appups"))
  end

  defp assert_exists(path) do
    %{size: size} = Path.join(@release_path, path) |> File.stat!()
    assert size > 0
  end

  defp docker_build_image(image_name, dockerfile_path) do
    Sys.cmd! "docker build . -f #{dockerfile_path} -t #{image_name}"
  end

  defp docker_run(image_name, cmd) do
    Sys.cmd! "docker run --rm=true -v $(pwd):/exreleasy -v $(pwd)/test_app:/test_app -w /test_app #{image_name} /bin/bash -c '#{cmd}'"
  end

end
