defmodule GiteeCli.Issues.List do
  use DoIt.Command,
    description: "List issues"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 2]

  option(:state, :string, "Issue states, multiple: (open, closed, rejected, processing)", default: "open,processing")
  option(:only_related_me, :integer, "Only list tasks associated with authorized users (0: No 1: Yes)", default: 1)
  option(:filter_child, :integer, "Filter sub tasks (0: no, 1: yes)", default: 0)
  option(:search, :string, "Search with keyword")
  option(:sort, :string, "Sort: (created_at, deadline, priority, updated_at)", default: "updated_at")
  option(:direction, :string, "Direction: (asc, desc)", default: "desc")
  option(:page, :integer, "Page", default: 1)
  option(:per_page, :integer, "Per page", default: 30)

  @headers %{
    "id" => "id" ,
    "ident" => "ident",
    "title" => "title",
    "state" => "state",
    "assignee" => [["remark"], ["name"]]
  }

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
      {200, %{"data" => pulls}, _response} ->
        {:ok, pulls}
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
