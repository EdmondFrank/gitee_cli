defmodule GiteeCli.Issues do
  use DoIt.Command,
    description: "issue related commands"

  subcommand(GiteeCli.Issues.List)
end
