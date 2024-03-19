defmodule GiteeCli do
  use DoIt.MainCommand,
    description: "Gitee CLI"

  command(GiteeCli.Auth)
end
