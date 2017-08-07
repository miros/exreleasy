defmodule Exreleasy.Release do

  alias Exreleasy.Sys

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

  @spec modify(Path.t, [{Path.t, binary}]) :: :ok | {:error, term}
  def modify(release_path, filelist) do
    Sys.in_tmp_dir(fn(tmp_path) ->
      with :ok <- extract_to(release_path, tmp_path),
           :ok <- add_files(tmp_path, filelist),
           :ok <- archive_to(release_path, tmp_path)
      do
        :ok
      end
    end)
  end

  defp add_files(_path, []), do: :ok
  defp add_files(path, [{file_name, data}|other_files]) do
    case File.write!(path |> Path.join(file_name), data, [:write]) do
      :ok ->
        add_files(path, other_files)
      {:error, error} ->
        {:error, error}
    end
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
