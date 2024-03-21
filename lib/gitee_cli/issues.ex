defmodule GiteeCli.Issues do
  use DoIt.Command,
    description: "Issues manage"

  subcommand(GiteeCli.Issues.List)
end
