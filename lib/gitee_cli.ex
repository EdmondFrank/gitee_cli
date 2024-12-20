defmodule GiteeCli do
  use DoIt.MainCommand,
    description: "Gitee CLI"

  command(GiteeCli.Llm)
  command(GiteeCli.Auth)
  command(GiteeCli.Pulls)
  command(GiteeCli.Issues)
  command(GiteeCli.AttachFiles)
  command(GiteeCli.Enterprises)
end
