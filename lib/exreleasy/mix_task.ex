defmodule Exreleasy.MixTask do

  @spec say(term) :: any
  def say(msg) do
    Mix.shell.info(msg)
  end

  @spec panic({:error, term}) :: no_return
  def panic({:error, error}) do
    panic(inspect(error))
  end

  @spec panic(String.t) :: no_return
  def panic(message) do
    say "Localizing erlang failed. Reason: #{message}"
    exit({:shutdown, 1})
  end

  @spec parse_cli(list, list) :: map | no_return
  def parse_cli(args, description) do
    results = description |> Optimus.new! |> Optimus.parse!(args)
    results.options
  end

end
