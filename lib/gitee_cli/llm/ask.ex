defmodule GiteeCli.Llm.Ask do
  use DoIt.Command,
    description: "Ask llm for help"

  alias LangChain.Message
  alias LangChain.Chains.LLMChain
  alias LangChain.Utils.ChainResult
  alias LangChain.ChatModels.ChatOpenAI
  alias GiteeCli.Llm.Functions
  import GiteeCli.Utils, only: [message: 2]

  @mdcat_command "mdcat"

  argument(:user_message, :string, "User message")

  def run(%{user_message: user_message}, params, %{
        config: %{
          "llm" => %{"api_base" => api_base, "model" => model, "api_key" => api_key},
          "cookie" => cookie,
          "default_ent_id" => ent_id
        }
      }) do
    Application.put_env(:langchain, :openai_key, api_key)

    initial_messages = [
      Message.new_system!("""
      You are a helpful AI assistant, proficient in using existing tools to help users solve problems and meet their needs.
      """),
      Message.new_user!(user_message)
    ]

    llm_chain = %{
      llm: ChatOpenAI.new!(%{endpoint: "#{api_base}/chat/completions", model: model}),
      custom_context: %{user_cookie: cookie, ent_id: ent_id, params: params},
      verbose: false
    }

    mdcat_render = System.find_executable(@mdcat_command)

    initial_chain =
      LLMChain.new!(llm_chain)
      |> LLMChain.add_messages(initial_messages)
      |> LLMChain.add_tools([Functions.get_user_issues()])

    conversation_loop(initial_chain, mdcat_render)
  end

  def run(_, _, context) do
    message("No available llm config was found, please setup it first", :yellow)
    help(context)
  end

  defp conversation_loop(llm_chain, mdcat_render)  do
    case LLMChain.run(llm_chain, mode: :while_needs_response) do
      {:ok, updated_chain} ->
        {:ok, result} = updated_chain |> ChainResult.to_string()
        # AI message in green
        render_message(result, mdcat_render)

        conversation_loop(
          LLMChain.add_message(updated_chain, Message.new_user!(get_user_input())),
          mdcat_render
        )

      _other ->
        message(
          "Error occurred when calling the model; please check the availability of the service and the correctness of the token.",
          :red
        )
    end
  end

  defp get_user_input do
    IO.gets("You: ")
    |> String.trim()
  end

  defp render_message(message, nil) do
    message
    |> Owl.Data.tag(:green)
    |> Owl.IO.puts()
  end

  defp render_message(message, mdcat) do
    System.cmd("sh", ["-c", "-l", "echo '#{message}' | #{mdcat}"])
    |> elem(0)
    |> Owl.Data.tag(:green)
    |> Owl.IO.puts()
  end
end
