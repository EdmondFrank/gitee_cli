defmodule GiteeCli do
  use DoIt.MainCommand,
    description: "Gitee CLI"

  command(GiteeCli.Auth)
  command(GiteeCli.Pulls)
  command(GiteeCli.Enterprises)
end
