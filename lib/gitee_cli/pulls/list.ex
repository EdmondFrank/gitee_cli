defmodule GiteeCli.Pulls.List do
  use DoIt.Command,
    description: "List pulls"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 2]

  option(:sort, :string, "Sort", default: "updated_at", allowed_values: ["created_at", "closed_at", "priority", "updated_at"])
  option(:direction, :string, "Sort direction", default: "desc", allowed_values: ["asc", "desc"])
  option(:page, :integer, "Page", default: 1)
  option(:per_page, :integer, "Per page", default: 20)
  option(:search, :string, "Search with keyword")
  option(:state, :string, "Filter by state", default: "opened", allowed_values: ["opened", "closed", "merged"])
  option(:scope, :string, "Filter by scope", default: "related_to_me", allowed_values: ["assigned_or_test", "related_to_me", "participate_in", "draft", "create","assign", "test"])

  @headers %{
    "id" => "id" ,
    "title" => "title",
    "state" => "state",
    "author" => [["remark"], ["name"]],
    "project" => [["name"]],
    "source_branch" => [["branch"]],
    "target_branch" => [["branch"]],
    "can_merge" => "can_merge"
  }

  @max_column_width 25

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
      {200, %{"data" => data}, _response} ->
        {:ok, data}
      {_, reason, _response} ->
        {:error, reason}
    end
  end

  defp print_list(auth, value, ent_id, params) do
    case load(auth, value, ent_id, params) do
      {:ok, pulls} ->
        pulls
        |> Enum.map(fn pull ->
          pull
          |> Map.take(Map.keys(@headers))
          |> try_convert_value_of_map_to_string(@headers)
        end)
        |> Owl.Table.new(border_style: :none, padding_x: 1, max_column_widths: fn _ -> @max_column_width end, truncate_lines: true)
        |> to_string()
        |> IO.puts()
      {:error, reason} ->
        message("error: #{inspect(reason)}", :red)
    end
  end
end
