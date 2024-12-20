defmodule GiteeCli.Llm.Functions do
  alias LangChain.Function

  import GiteeCli.Utils, only: [try_convert_value_of_map_to_string: 2]

  def get_user_issues do
    fields = %{
      "id" => "id" ,
      "ident" => "ident",
      "title" => "title",
      "state" => "state",
      "description" => "description",
      "created_at" => "created_at",
      "updated_at" => "updated_at",
      "deadline" => "deadline",
      "assignee" => [["remark"], ["name"]],
      "collaborators" => [["remark"], ["name"]]
    }
    Function.new!(%{
      name: "get_user_issues",
      description: "Returns the task list information for the current user.",
      function: fn _args, %{user_cookie: user_cookie, ent_id: ent_id, params: params} = _context ->
        params =
          params
          |> Map.put(:only_related_me, 1)
          |> Map.put(:per_page, 10)
        {:ok, issues} = GiteeCli.Issues.List.load(:cookie, user_cookie, ent_id, params)
        data = Enum.map(issues, fn i -> Map.take(i, Map.keys(fields)) |>  try_convert_value_of_map_to_string(fields) end)
        {:ok, Jason.encode!(data)}
      end
    })
  end
end
