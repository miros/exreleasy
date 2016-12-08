defmodule Exreleasy.Sys do

  def asset_path(path_parts) do
    Path.join([:code.priv_dir(Exreleasy.app_name)] ++ path_parts)
  end

  def copy_path(source, dest) do
    File.rm_rf(dest)
    File.cp_r!(source, dest)
  end

  def copy_file(source, dest) do
    File.rm(dest)
    File.write!(dest, File.read!(source), [:write])
  end

  def which(binary_name) do
    case System.cmd("which", [binary_name]) do
      {path, 0} ->
        path |> String.trim |> Path.expand
      _ ->
        raise "Executable #{binary_name} not found in path"
    end
  end

  def with_env(new_params, cb) do
    old_params = Map.take(System.get_env, Map.keys(new_params))
    try do
      System.put_env(new_params)
      cb.()
    after
      System.put_env(old_params)
    end
  end

  def cmd!(command) do
    case Mix.shell.cmd(command) do
      0 -> :ok
      status -> raise "Shell command failed cmd:#{command} status:#{status}"
    end
  end

end
