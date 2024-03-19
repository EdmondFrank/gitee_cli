defmodule GiteeCli.Pulls do
  use DoIt.Command,
    description: "pull request related commands"

  subcommand(GiteeCli.Pulls.List)
end
