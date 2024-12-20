defmodule GiteeCli.Enterprises.List do
  use DoIt.Command,
    description: "List enterprises"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 1]

  option(:sort, :string, "Sort", default: "created_at", allowed_values: ["name", "created_at"])
  option(:direction, :string, "Sort direction", default: "desc", allowed_values: ["asc", "desc"])
  option(:page, :integer, "Page", default: 1)
  option(:per_page, :integer, "Per page", default: 30)

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
      {200, %{"data" => data}, _response} ->
        {:ok, data}
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
