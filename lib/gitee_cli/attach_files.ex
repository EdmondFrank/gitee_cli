defmodule GiteeCli.AttachFiles do
  use DoIt.Command,
    description: "Attach Files manage"

  subcommand(GiteeCli.AttachFiles.Upload)
end
