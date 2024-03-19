import Config

config :do_it, DoIt.Commfig,
  dirname: Path.join(System.user_home(), ".gitee_cli"),
  filename: "config.json"

config :elixir, ansi_enabled: true
