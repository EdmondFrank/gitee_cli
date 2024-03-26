defmodule GiteeCli.Issues.Create do
  use DoIt.Command,
    description: "Create a issue"

  import GiteeCli.Utils, only: [message: 2, try_convert_value_of_map_to_string: 2]

  @headers %{
    "id" => "id" ,
    "ident" => "ident",
    "title" => "title",
    "state" => "state",
    "assignee" => [["remark"], ["name"]]
  }

  option(:title, :string, "Issue title", alias: :t)
  option(:description, :string, "Issue description", alias: :d)
  option(:assignee_id, :integer, "Issue assignee", alias: :a)
  option(:collaborator_ids, :integer, "Issue assignee", alias: :c, keep: true)
  option(:issue_type_id, :integer, "Issue type", alias: :i)
  option(:parent, :string, "Associate parent task by keywords", alias: :p)
  option(:skip_desc, :boolean, "Skip issue description", alias: :s)

  def run(_args, params, %{config: %{"cookie" => cookie, "default_ent_id" => ent_id}}) do
    create_task(:cookie, cookie, ent_id, params)
  end

  def run(_args, params, %{config: %{"access_token" => token, "default_ent_id" => ent_id}}) do
    create_task(:access_token, token, ent_id, params)
  end

  def run(_args, _opts, context) do
    help(context)
  end

  def create_task(auth, value, ent_id, params) do
    client = GiteeCat.Client.new(%{auth => value})
    params = attach_issue_type(client, ent_id, params)
    params = attach_parent_issue(client, ent_id, params)
    params = attach_title(params)
    params = attach_desc(params)
    case GiteeCat.Issues.create(client, ent_id, params) do
      {201, data, _resp} ->
        message("Issue #{data["issue_url"]} created.", :green)
      {_, reason, _response} ->
        message("Error: #{inspect(reason)}.", :red)
    end
  end


  defp attach_parent_issue(client, ent_id, %{parent: parent} = params) when is_binary(parent) and byte_size(parent) > 0 do
    case GiteeCat.Issues.list(client, ent_id, %{search: parent}) do
      {200, %{"data" => data}, _response} ->
        message("Please select a parent issue: ", :yellow)
        parent_id =
          data
          |> Owl.IO.select(render_as:
        fn %{"title" => title, "ident" => ident} ->
          [
            Owl.Data.tag(title, :light_black),
            " ",
            Owl.Data.tag("[#{ident}]", :cyan)
          ]
        end)
        |> Map.get("id")
          message("The current sub issues under the parent issue are: ", :yellow)
          case GiteeCat.Issues.children(client, ent_id, parent_id) do
            {200, %{"data" => data}, _response} ->
              data
              |> Enum.map(fn issue ->
                issue
                |> Map.take(Map.keys(@headers))
                |> try_convert_value_of_map_to_string(@headers)
              end)
              |> Owl.Table.new(border_style: :none, padding_x: 1)
              |> to_string()
              |> IO.puts()
            {_, reason, _response} ->
              message("error: #{inspect(reason)}", :red)
          end
          params
          |> Map.delete(:parent)
          |> Map.put(:parent_id, parent_id)
      _ -> params
    end
  end
  defp attach_parent_issue(_client, _ent_id, params), do: params

  defp attach_desc(params) do
    unless params[:skip_desc] do
      desc = Owl.IO.open_in_editor(params[:description], "alacritty -e vim")
      Map.put(params, :description, desc)
    else
      Map.delete(params, :skip_desc)
    end
  end

  defp attach_title(%{title: title} = params) when is_binary(title) and byte_size(title) > 0, do: params
  defp attach_title(params) do
    message("Please input issue title: ", :yellow)
    title = Owl.IO.input()
    Map.put(params, :title, title)
  end

  defp attach_issue_type(_, _, %{issue_type_id: id} = params) when is_integer(id) and id > 0, do: params
  defp attach_issue_type(client, ent_id, params) do
    case GiteeCat.IssueTypes.list(client, ent_id) do
      {200, %{"data" => data}, _resp} ->
        %{"id" => issue_type_id, "template" => issue_template} =
          data
          |> Owl.IO.select(render_as:
        fn %{"title" => title, "category" => category} ->
          [
            Owl.Data.tag(title, :light_black),
            " ",
            Owl.Data.tag("[#{category}]", :cyan)
          ]
        end)
        |> Map.take(["id", "template"])
          params
          |> Map.put(:issue_type_id, issue_type_id)
          |> Map.put_new(:description, issue_template)
        _ -> params
    end
  end
end
