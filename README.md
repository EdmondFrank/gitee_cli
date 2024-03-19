# Gitee CLI

The `gitee_cli` tool allows you to interacte with Gitee using either an access token or a cookie.

## Build

```
mix deps.get
mix escript.build
```

## Usage

```
Usage: gitee_cli COMMAND

Gitee CLI

Commands:
  enterprises     enterprise related commands
  pulls           pull request related commands
  auth            Gitee CLI auth module

Run 'gitee_cli COMMAND --help' for more information on a command.
```

### Auth
```
Usage: gitee_cli auth [OPTIONS]

Gitee CLI auth module

Options:
      --help           Print this help
  -t, --access-token   OAuth token for Gitee OpenAPI
  -f, --cookies-file   Path to a file containing cookie
  -d, --delete         Delete the auth cache, options: `cookie`, `access_token`
```

### Enterprises
```
Usage: gitee_cli enterprises SUBCOMMAND

enterprise related commands

Subcommands:
  default     Get or set my default enterprises
  list        List enterprises

Run 'gitee_cli enterprises SUBCOMMAND --help' for more information on a subcommand.
```

### Pulls
```

Usage: gitee_cli pulls SUBCOMMAND

pull request related commands

Subcommands:
  list     List pull requests

Run 'gitee_cli pulls SUBCOMMAND --help' for more information on a subcommand.
```
