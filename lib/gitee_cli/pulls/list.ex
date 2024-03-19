defmodule GiteeCli.Pulls.List do
  use DoIt.Command,
    description: "List pull requests"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 1]

  @headers ["id", "title", "state"]

  def run(_args, params, %{config: %{"cookie" => cookie, "default_ent_id" => ent_id}}) do
    print_list(:cookie, cookie, ent_id, params)
  end

  def run(_args, params, %{config: %{"access_token" => token, "default_ent_id" => ent_id}}) do
    print_list(:access_token, token, ent_id, params)
  end

  def run(_args, _opts, context) do
    message("Please make sure you have set up your default enterprise and auth correctly first!", :yellow)
    help(context)
  end

  def load(auth, value, ent_id, params) do
    case GiteeCat.Client.new(%{auth => value})
    |> GiteeCat.Pulls.list(ent_id, params) do
      {200, %{"data" => pulls}, _response} ->
        {:ok, pulls}
      {_, reason, _response} ->
        {:error, reason}
    end
  end

  defp print_list(auth, value, ent_id, params) do
    case load(auth, value, ent_id, params) do
      {:ok, pulls} ->
        pulls
        |> Enum.map(fn pull -> Map.take(pull, @headers) |> try_convert_value_of_map_to_string() end)
        |> Owl.Table.new(border_style: :none, padding_x: 1)
        |> to_string()
        |> IO.puts()
      {:error, reason} ->
        message("error: #{inspect(reason)}", :red)
    end
  end
end
