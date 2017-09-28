defmodule Exreleasy.ReleaseDir do

  def add_files(_path, []), do: :ok
  def add_files(path, [{file_name, data}|other_files]) do
    case File.write!(path |> Path.join(file_name), data, [:write]) do
      :ok ->
        add_files(path, other_files)
      {:error, error} ->
        {:error, error}
    end
  end

end
