defmodule GiteeCliTest do
  use ExUnit.Case
  doctest GiteeCli

  test "first test" do
    assert GiteeCli.command() == {"gitee_cli", "Gitee CLI"}
  end
end
