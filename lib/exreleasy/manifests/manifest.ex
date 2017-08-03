defmodule Exreleasy.Manifests.Manifest do

  alias __MODULE__
  alias Exreleasy.Manifests.App

  defstruct [
    apps: %{}
  ]

  @type t :: %__MODULE__{
    apps: %{atom => App.t}
  }

  @spec new(map) :: t
  def new(options) do
    apps = options["apps"] |> Enum.map(fn {k,v} -> {String.to_atom(k), App.new(v)} end) |> Enum.into(%{})
    %Manifest{apps: apps}
  end

  @spec digest([atom]) :: {:ok, t} | {:error, term}
  def digest(apps) do
    with {:ok, app_digests} <- digest_apps(apps, %{}) do
      {:ok, %Manifest{apps: app_digests}}
    end
  end

  @spec apps_set(t) :: Set.t
  def apps_set(manifest) do
    manifest.apps |> Map.keys |>  MapSet.new()
  end

  defp digest_apps([], results), do: {:ok, results}
  defp digest_apps([app|other_apps], results) do
    with {:ok, app_manifest} <- App.digest(app),
      do: digest_apps(other_apps, Map.put(results, app, app_manifest))
  end

end
