defmodule GiteeCli.Enterprises.Default do
  use DoIt.Command,
    description: "Get or set my default enterprises"

  alias GiteeCli.Enterprises

  import GiteeCli.Utils, only: [message: 2]

  @headers ["id", "name", "path"]

  def run(_args, params, %{config: %{"cookie" => cookie, "default_ent_id" => ent_id}}) do
    print_default(:cookie, cookie, params, ent_id)
  end

  def run(_args, params, %{config: %{"access_token" => token, "default_ent_id" => ent_id}}) do
    print_default(:access_token, token, params, ent_id)
  end

  def run(_args, params, %{config: %{"cookie" => cookie}}) do
    print_default(:cookie, cookie, params)
  end

  def run(_args, params, %{config: %{"access_token" => token}}) do
    print_default(:access_token, token, params)
  end

  defp print_default(auth, value, params, ent_id \\ nil) do
    case Enterprises.List.load(auth, value, params) do
      {:ok, ents} ->
        message("You could change the default enterprise by input item number: (* => default)", :green)
        ents
        |> Enum.map(fn ent -> Map.take(ent, @headers) end)
        |> Owl.IO.select(render_as:
          fn %{"id" => id, "name" => name, "path" => path} ->
            [
            if(id == ent_id, do: "* ", else: "  "),
            if(id == ent_id, do: Owl.Data.tag(path, :green), else: Owl.Data.tag(path, :cyan)),
            " ",
            Owl.Data.tag(name, :light_black)
            ]
        end)
        |> get_in(["id"])
        |> Kernel.then(&DoIt.Commfig.set("default_ent_id", &1))
      {:error, reason} ->
        message("error: #{inspect(reason)}", :red)
    end
  end
end
