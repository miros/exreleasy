defmodule Exreleasy.MixTask do

  def say(msg) do
    Mix.shell.info(msg)
  end

  def panic({:error, error}) do
    panic(inspect(error))
  end

  def panic(message) do
    say "Localizing erlang failed. Reason: #{message}"
    exit({:shutdown, 1})
  end

end
