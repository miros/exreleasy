defmodule Exreleasy.HotReloaderTest do

  use ExUnit.Case
  alias Exreleasy.HotReloader

  test "reloads code" do
    assert :ok == HotReloader.reload(Node.self(), "/new/path", [:app_name],
      reload_configs: false, reloader: fake_reloader(self()))
    assert_received {:app_reloaded, :app_name, "/new/path/_build/test/lib/app_name"}
  end

  test "reloads configs" do
    assert :ok == HotReloader.reload(Node.self(), "./test_app", [:app_name],
      reload_configs: true, reloader: fake_reloader(self()))
    assert {:ok, :test_value} == Application.fetch_env(:test_app, :test_key)
  end

  def fake_reloader(receiver) do
    fn(app_name, new_path) ->
      send receiver, {:app_reloaded, app_name, new_path}
    end
  end

end
