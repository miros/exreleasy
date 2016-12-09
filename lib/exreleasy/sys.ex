defmodule Exreleasy.Sys do

  def asset_path(asset_name) do
    Path.join([:code.priv_dir(Exreleasy.app_name), asset_name])
  end

  def template_asset(asset_name, dest, params) do
    data = EEx.eval_file(asset_path(asset_name), params)
    create_file(data, dest)
  end

  def copy_path(source, dest) do
    File.rm_rf(dest)
    File.cp_r!(source, dest)
  end

  def create_file(data, dest) do
    File.mkdir_p!(Path.dirname(dest))
    File.rm(dest)
    File.write!(dest, data, [:write])
  end

  def copy_file(source, dest) do
    create_file(File.read!(source), dest)
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

  def chmod_as_executable(path) do
    File.chmod!(path, 0o755) 
  end

end
