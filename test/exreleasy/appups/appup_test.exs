defmodule Exreleasy.Appups.AppupTest do
  use ExUnit.Case

  alias Exreleasy.Appups.Appup
  alias Exreleasy.Manifests.App

  test "modules are the same" do
    app = %App{
      version: "0.0.1",
      modules: %{SomeModule => "hash"}
    }

    assert {:error, :unchanged} == Appup.make(app, app)
  end

  test "modules are updated" do
    old_app = %App{
      version: "0.0.1",
      modules: %{SomeModule => "hash", SomeOtherModule => "hash"}
    }

    new_app = %App{
      version: "0.0.2",
      modules: %{SomeModule => "new_hash", SomeOtherModule => "hash"}
    }

    description = {'0.0.2',
      [{'0.0.1', [{:update, SomeModule, {:advanced, :ok}}]}],
      [{'0.0.1', [{:update, SomeModule, {:advanced, :ok}}]}],
    }

    assert {:ok, description} == Appup.make(old_app, new_app)
  end

  test "modules are added" do
    old_app = %App{
      version: "0.0.1",
      modules: %{SomeOtherModule => "hash"}
    }

    new_app = %App{
      version: "0.0.2",
      modules: %{SomeModule => "new_hash", SomeOtherModule => "hash"}
    }

    description = {'0.0.2',
      [{'0.0.1', [{:load_module, SomeModule}]}],
      [{'0.0.1', [{:delete_module, SomeModule}]}],
    }

    assert {:ok, description} == Appup.make(old_app, new_app)
  end

  test "modules are removed" do
    old_app = %App{
      version: "0.0.1",
      modules: %{SomeModule => "new_hash", SomeOtherModule => "hash"}
    }

    new_app = %App{
      version: "0.0.2",
      modules: %{SomeOtherModule => "hash"}
    }

    description = {'0.0.2',
      [{'0.0.1', [{:delete_module, SomeModule}]}],
      [{'0.0.1', [{:load_module, SomeModule}]}],
    }

    assert {:ok, description} == Appup.make(old_app, new_app)
  end

end
