defmodule Exreleasy.Release do

  alias Exreleasy.Sys

  @spec path() :: String.t
  def path do
    Path.join(File.cwd!, "release")
  end

  @spec archive_path() :: String.t
  def archive_path do
    Path.join(path(), "archive")
  end

  @spec make(String.t) :: :ok | no_return
  def make(dest) do
    dest |> Path.dirname |> File.mkdir_p!
    Mix.Task.run("deps.get")
    Mix.Task.run("compile")
    Mix.Task.run("exreleasy.localize")
    archive_to(dest)
    :ok
  end

  @spec archive_to(String.t) :: :ok | no_return
  defp archive_to(dest) do
    Sys.cmd!("tar -czf #{dest} --exclude='./release/archive' .")
  end

end
