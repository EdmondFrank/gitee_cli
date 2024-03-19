defmodule GiteeCli.Enterprises do
  use DoIt.Command,
    description: "enterprise related commands"

  subcommand(GiteeCli.Enterprises.List)
  subcommand(GiteeCli.Enterprises.Default)
end
