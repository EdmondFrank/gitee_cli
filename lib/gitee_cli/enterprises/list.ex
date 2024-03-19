defmodule GiteeCli.Enterprises.List do
  use DoIt.Command,
    description: "List enterprises"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 1]

  @headers ["id", "name", "path"]

  def run(_args, params, %{config: %{"cookie" => cookie}}) do
    print_list(:cookie, cookie, params)
  end

  def run(_args, params, %{config: %{"access_token" => token}}) do
    print_list(:access_token, token, params)
  end

  def load(auth, value, params) do
    case GiteeCat.Client.new(%{auth => value})
    |> GiteeCat.Enterprises.list(params) do
      {200, %{"data" => ents}, _response} ->
        {:ok, ents}
      {_, reason, _response} ->
        {:error, reason}
    end
  end

  defp print_list(auth, value, params) do
    case load(auth, value, params) do
      {:ok, ents} ->
        ents
        |> Enum.map(fn ent -> Map.take(ent, @headers) |> try_convert_value_of_map_to_string() end)
        |> Owl.Table.new(border_style: :none, padding_x: 1)
        |> to_string()
        |> IO.puts()
      {:error, reason} ->
        message("error: #{inspect(reason)}", :red)
    end
  end
end
