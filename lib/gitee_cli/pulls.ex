defmodule GiteeCli.Pulls do
  use DoIt.Command,
    description: "Pulls manage"

  subcommand(GiteeCli.Pulls.List)
end
