# Exreleasy

A very simple tool for releasing elixir applications.

Many people use erlang releases only for one reason: to bundle local erlang runtime inside the project. But unfortunatelly you loose the ability to run mix.

This tool bundles erlang/elixir locally and creates wrapper scripts for running mix/iex.

Credit for the idea goes to @savonarola

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
    ./release/binstubs/iex_mix
    ./release/binstubs/erl
    ./release/binstubs/elixir

To make a release:

    mix exreleasy.release v0.0.1

This will create `./release/archive/v0.0.1.tar.gz` archive with your project (including ./release directory)

To hot reload your code:

* Step 1

Generate appup file for all applications of your project.

    mix exreleasy.create_appup --old-release ./release/archive/v0.0.1.tar.gz --new-release ./release/archive/v0.0.2.tar.gz --appup ./appup_1_to_2

Alternatively use release/exreleasy.json from old release (fetch it from production maybe)

    mix exreleasy.create_appup --old-release /path/to/old/manifest.json --new-release ./release/archive/v0.0.2.tar.gz --appup ./appup_1_to_2

* Step 2

Edit appup file to include only modules you want to touch
Available instructions - http://erlang.org/doc/man/appup.html

    vim ./appup_1_to_2

* Step 3

Apply appup file to release (creates individual appup files in ebin directories)

    mix exreleasy.apply_appup --release ./release/archive/v0.0.2.tar.gz --appup ./appup_1_to_2

Alternatively Steps 1-3 can be automized using provided script

    ./deps/exreleasy/priv/prepare_hot_release prod /path/to/old/release.tar.gz /path/to/new/release.tar.gz

* Step 4

Deploy new code to server

* Step 5

Reload code

    env MIX_ENV=prod ./release/binstubs/mix exreleasy.hot_reload --node your_node@your_host --cookie your_cookie --new-path path_to_new_code --reload-configs
