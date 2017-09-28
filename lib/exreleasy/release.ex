defmodule Exreleasy.Release do

  alias Exreleasy.Sys
  alias Exreleasy.ReleaseDir

  @spec path() :: String.t
  def path do
    Path.join(File.cwd!, dir())
  end

  @spec dir() :: String.t
  def dir do
    "release"
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

  @spec read_file(Path.t, Path.t) :: {:ok, binary} | {:error, term}
  def read_file(release_path, file_path) do
    file_path = "./#{file_path}" |> String.to_charlist()
    with {:ok, [{_, data}]} <- :erl_tar.extract(release_path, [:compressed, :memory, {:files, [file_path]}]) do
      {:ok, data}
    else
      :ok -> {:error, {:file_not_found, file_path}}
    end
  end

  @spec add_files(Path.t, [{Path.t, binary}]) :: :ok | {:error, term}
  def add_files(release_path, filelist) do
    modify_archive(release_path, fn(path) -> ReleaseDir.add_files(path, filelist) end)
  end

  def modify_archive(release_path, action) do
    Sys.in_tmp_dir(fn(tmp_path) ->
      with :ok <- extract_to(release_path, tmp_path),
           :ok <- action.(tmp_path),
           :ok <- archive_to(release_path, tmp_path)
      do
        :ok
      end
    end)
  end

  @spec archive_to(Path.t) :: :ok | no_return
  defp extract_to(release_path, dest) do
    Sys.cmd!("tar -x -f #{release_path} -C #{dest}")
  end

  @spec archive_to(Path.t) :: :ok | no_return
  defp archive_to(dest, source \\ File.cwd!) do
    Sys.cmd!("tar -cz --exclude='./release/archive' -f #{dest} -C #{source} .")
  end

end
