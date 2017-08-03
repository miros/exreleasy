defmodule Exreleasy.Manifests.App do

  alias __MODULE__

  @derive [Poison.Encoder]
  defstruct [:version, :modules]

  @type t :: %__MODULE__{
    modules: %{module => String.t},
    version: String.t
  }

  @spec new(map) :: t
  def new(options) do
    modules = options["modules"] |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end) |> Enum.into(%{})
    %App{version: options["version"], modules: modules}
  end

  @spec digest(atom) :: t
  def digest(app_name) do

    # TODO temporary hack
    :code.lib_dir(:exreleasy)
    |> to_string
    |> String.replace("exreleasy", to_string(app_name))
    |> Path.join("ebin")
    |> Code.prepend_path()

    with :ok <- Application.load(app_name),
         {:ok, modules} <- :application.get_key(app_name, :modules),
         {:ok, vsn} <- :application.get_key(app_name, :vsn) do
      {:ok, %App{modules: digest_modules(modules), version: to_string(vsn)}}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp digest_modules(modules) do
    modules
      |> Enum.map(&({&1, module_version(&1)}))
      |> Enum.into(%{})
  end

  defp module_version(module) do
    module.module_info(:md5) |> Base.encode16(case: :lower)
  end

end
