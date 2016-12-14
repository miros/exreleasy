defmodule ExreleasyTest do
  use ExUnit.Case
  doctest Exreleasy

  alias Exreleasy.Sys

  @elixir_image "exreleasy_test_elixir"
  @bare_image "exreleasy_test_bare"

  setup_all do
    docker_build_image(@elixir_image, "test/Dockerfile.elixir")
    docker_build_image(@bare_image, "test/Dockerfile.bare")
    :ok
  end

  @release_path "test_app/release"

  setup do
    File.rm_rf!(@release_path)
    :ok
  end

  @tag timeout: 2 * 60 * 1000
  test "it successfully releases project" do
    docker_run(@elixir_image, "mix deps.get && mix compile && mix exreleasy.release test_release")

    assert MapSet.new(File.ls!(@release_path)) == MapSet.new(~w{erlang elixir .mix .hex binstubs archive})

    %{size: release_size} = File.stat!("#{@release_path}/archive/test_release.tar.gz")
    assert release_size > 0

    docker_run(@bare_image, ~s{./release/binstubs/mix run -e ":ok"})
    docker_run(@bare_image, ~s{./release/binstubs/elixir -e ":ok"})
    docker_run(@bare_image, ~s{./release/binstubs/iex -e "exit(0)"})
    docker_run(@bare_image, ~s{./release/binstubs/iex_mix run -e ":ok"})
  end

  defp docker_build_image(image_name, dockerfile_path) do
    Sys.cmd! "docker build . -f #{dockerfile_path} -t #{image_name}"
  end

  defp docker_run(image_name, cmd) do
    Sys.cmd! "docker run --rm=true -v $(pwd):/exreleasy -v $(pwd)/test_app:/test_app -w /test_app #{image_name} /bin/bash -c '#{cmd}'"
  end

end
