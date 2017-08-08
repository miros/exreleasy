defmodule Exreleasy.Manifests.Storage do

  alias Exreleasy.Manifests.Manifest
  alias Exreleasy.Release

  @spec load(Path.t) :: {:ok, Manifest.t} | {:error, term}
  def load(path) do
    with {:ok, data} <- read(path),
      do: deserialize(data)
  end

  @spec save(Path.t, Manifest.t) :: :ok | {:error, term}
  def save(dest, manifest) do
    with {:ok, data} <- serialize(manifest),
      do: File.write(dest, data)
  end

  defp read(path) do
    if String.ends_with?(path, ".tar.gz") do
      Release.read_file(path, Manifest.in_release_path())
    else
      File.read(path)
    end
  end

  defp serialize(data), do: Poison.encode(data)

  defp deserialize(data) do
    with {:ok, options} <- Poison.decode(data) do
      {:ok, Manifest.new(options)}
    end
  end

end
