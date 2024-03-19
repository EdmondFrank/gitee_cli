defmodule GiteeCli.Auth do
  use DoIt.Command,
    description: "Gitee CLI auth module"

  import GiteeCli.Utils, only: [message: 2]

  option(:access_token, :string, "OAuth token for Gitee OpenAPI", alias: :t)
  option(:cookies_file, :string, "Path to a file containing cookie", alias: :f)
  option(:delete, :string, "Delete the auth cache, options: `cookie`, `access_token`", alias: :d)

  def run(_, %{cookies_file: cookies_file}, _) do
    case File.read(Path.expand(cookies_file)) do
      {:ok, cookie_jar} ->
        cookie_jar
        |> String.trim
        |> Kernel.then(&do_auth_and_save(:cookie, &1))
      {:error, reason} ->
        message("Could not open file `#{cookies_file}`, error: #{inspect(reason)}", :red)
    end
  end

  def run(_, %{access_token: access_token}, _) do
    do_auth_and_save(:access_token, access_token, true, "access_token")
  end

  def run(_, %{delete: "cookie"}, _), do: DoIt.Commfig.unset("cookie")
  def run(_, %{delete: "access_token"}, _), do: DoIt.Commfig.unset("access_token")

  def run(_, _, %{config: %{"cookie" => cookie}}) do
    do_auth_and_save(:cookie, cookie, false)
  end

  def run(_, _, %{config: %{"access_token" => token}}) do
    do_auth_and_save(:access_token, token, false)
  end

  def run(_, _, context) do
    message("No available auth was found, please set it first", :yellow)
    help(context)
  end

  defp do_auth_and_save(auth, value, save \\ true, key \\ "cookie") do
    case GiteeCat.Client.new(%{auth => value}) |> GiteeCat.Users.me do
      {200, %{"name" => name}, _response} ->
        if save, do: DoIt.Commfig.set(key, value)
        message("Hi「#{name}」! You've authenticated", :green)
      {_, data, _response} ->
        message("Authorizate error, reason: #{inspect(data)}", :red)
    end
  end
end
