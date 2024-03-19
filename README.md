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
  auth     Gitee CLI auth module

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
