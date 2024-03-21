defmodule GiteeCli.Issues.List do
  use DoIt.Command,
    description: "List issues"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 2]

  option(:state, :string, "Filter by states, multiple", default: "open", allowed_values: ["open", "closed", "rejected", "processing"], keep: true)
  option(:only_related_me, :integer, "Is only related with me (0: no 1: yes)", default: 1, allowed_values: [0, 1])
  option(:filter_child, :integer, "Is show subtasks (0: no, 1: yes)", default: 0, allowed_values: [0, 1])
  option(:search, :string, "Search with keyword")
  option(:sort, :string, "Sort", default: "updated_at", allowed_values: ["created_at", "deadline", "priority", "updated_at"])
  option(:direction, :string, "Sort direction", default: "desc", allowed_values: ["asc", "desc"])
  option(:page, :integer, "Page", default: 1)
  option(:per_page, :integer, "Per page", default: 30)

  @headers %{
    "id" => "id" ,
    "ident" => "ident",
    "title" => "title",
    "state" => "state",
    "assignee" => [["remark"], ["name"]]
  }

  def run(args, %{state: state} = params, context) when is_list(state) do
    run(args, %{params | state: Enum.join(state, ",")}, context)
  end

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
    |> GiteeCat.Issues.list(ent_id, params) do
      {200, %{"data" => data}, _response} ->
        {:ok, data}
      {_, reason, _response} ->
        {:error, reason}
    end
  end

  defp print_list(auth, value, ent_id, params) do
    case load(auth, value, ent_id, params) do
      {:ok, issues} ->
        issues
        |> Enum.map(fn issue ->
          issue
          |> Map.take(Map.keys(@headers))
          |> try_convert_value_of_map_to_string(@headers)
        end)
        |> Owl.Table.new(border_style: :none, padding_x: 1)
        |> to_string()
        |> IO.puts()
      {:error, reason} ->
        message("error: #{inspect(reason)}", :red)
    end
  end
end
