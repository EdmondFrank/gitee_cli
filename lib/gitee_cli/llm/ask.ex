defmodule GiteeCli.Llm.Ask do
  use DoIt.Command,
    description: "Ask llm for help"

  alias LangChain.Message
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias GiteeCli.Llm.Functions
  import GiteeCli.Utils, only: [message: 2]

  argument(:user_message, :string, "User message")

  def run(%{user_message: user_message}, params, %{
        config: %{
          "llm" => %{"api_base" => api_base, "model" => model, "api_key" => api_key},
          "cookie" => cookie,
          "default_ent_id" => ent_id
        }
      }) do
    Application.put_env(:langchain, :openai_key, api_key)

    messages = [
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

    case LLMChain.new!(llm_chain)
         |> LLMChain.add_messages(messages)
         |> LLMChain.add_tools([Functions.get_user_issues()])
         |> LLMChain.run(mode: :while_needs_response) do
      {:ok, %{last_message: %{content: content}}} ->
        IO.puts(content)

      reason ->
        message(
          "Error occurred when calling the model; please check the availability of the service and the correctness of the token.",
          :red
        )
    end
  end

  def run(_, _, context) do
    message("No available llm config was found, please setup it first", :yellow)
    help(context)
  end
end
