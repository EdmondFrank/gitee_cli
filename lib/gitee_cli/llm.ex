defmodule GiteeCli.Llm do
  use DoIt.Command,
    description: "llm related coemmands"
  subcommand(GiteeCli.Llm.Ask)
  subcommand(GiteeCli.Llm.Setup)
end
