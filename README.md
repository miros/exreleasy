# Exreleasy

A very simple tool for releasing elixir applications.

Many people use erlang releases only for one reason: to bundle local erlang runtime inside the project. But unfortunatelly you loose the ability to run mix.

This tool bundles erlang/elixir locally and creates wrapper scripts for running mix/iex.

## Installation

  1. Add `exreleasy` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:exreleasy, "~> 0.1.0"}]
    end
    ```
    
## Usage

To bundle erlang/elixir inside your project:

    mix exreleasy.localize
    
This will create `./release` directory with erlang/elixir and wrapper scripts:

    ./release/binstubs/mix
    ./release/binstubs/iex
    ./release/binstubs/erl
    
To make a release:

    mix exreleasy.release v0.0.1
    
This will create `./release/archive/v0.0.1.tar.gz` archive with your project (including ./release directory)
