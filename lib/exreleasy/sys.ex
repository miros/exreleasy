defmodule Exreleasy.Sys do

  @spec asset_path(String.t) :: String.t
  def asset_path(asset_name) do
    Path.join([:code.priv_dir(Exreleasy.app_name), asset_name])
  end

  @spec template_asset(String.t, String.t, keyword()) :: :ok | no_return
  def template_asset(asset_name, dest, params) do
    data = EEx.eval_file(asset_path(asset_name), params)
    create_file(data, dest)
  end

  @spec copy_path(String.t, String.t) :: :ok | no_return
  def copy_path(source, dest) do
    File.rm_rf(dest)
    File.cp_r!(source, dest)
    :ok
  end

  @spec create_file(String.t, String.t) :: :ok | no_return
  def create_file(data, dest) do
    File.mkdir_p!(Path.dirname(dest))
    File.rm(dest)
    File.write!(dest, data, [:write])
    :ok
  end
  
  @spec copy_file(String.t, String.t) :: :ok | no_return
  def copy_file(source, dest) do
    create_file(File.read!(source), dest)
  end

  @spec which(String.t) :: String.t
  def which(binary_name) do
    case System.cmd("which", [binary_name]) do
      {path, 0} ->
        path |> String.trim |> Path.expand
      _ ->
        raise "Executable #{binary_name} not found in path"
    end
  end

  @spec with_env(map, fun) :: term
  def with_env(new_params, cb) do
    old_params = Map.take(System.get_env, Map.keys(new_params))
    try do
      System.put_env(new_params)
      cb.()
    after
      System.put_env(old_params)
    end
  end
  
  @spec cmd!(String.t) :: :ok | no_return
  def cmd!(command) do
    case Mix.shell.cmd(command) do
      0 -> :ok
      status -> raise "Shell command failed cmd:#{command} status:#{status}"
    end
  end

  @spec chmod_as_executable(String.t) :: :ok | no_return
  def chmod_as_executable(path) do
    File.chmod!(path, 0o755) 
  end

end
