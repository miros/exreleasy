defmodule Exreleasy.Application do

  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exreleasy.HotReloader, []),
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Exreleasy.Supervisor)
  end

end
