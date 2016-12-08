defmodule Exreleasy.Release do

  alias Exreleasy.Sys

  def path do
    Path.join(File.cwd!, "release")
  end

  def archive_path do
    Path.join(path, "archive")
  end

  def make(dest) do
    Mix.Task.run("deps.get")
    Mix.Task.run("compile")
    Mix.Task.run("exreleasy.localize")
    archive_to(dest)
  end

  defp archive_to(dest) do
    Sys.cmd!("tar -czf #{dest} --exclude='./release/archive' .")
  end

end
