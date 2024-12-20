defmodule GiteeCli.Llm.Setup do
  use DoIt.Command,
    description: "Setup LLM model"

  @llm "llm"

  import GiteeCli.Utils, only: [message: 2]

  option(:api_key, :string, "API key", alias: :t)
  option(:api_base, :string, "API base url", default: "https://ai.gitee.com/v1", alias: :l)
  option(:model, :string, "Model", default: "Qwen2.5-Coder-32B-Instruct", alias: :m)
  option(:reset, :boolean, "Reset Model configs", alias: :r)

  def run(_, %{api_key: _api_key} = params, _) do
    do_setup_llm(params)
  end

  def run(_, _, context) do
    message("No available api_key was found, please set it first", :yellow)
    help(context)
  end

  defp do_setup_llm(%{reset: true}) do
    DoIt.Commfig.set(@llm, %{})
    message("Reset llm configures successfully", :green)
  end

  defp do_setup_llm(%{api_base: _api_base, model: _model, api_key: _api_key} = value) do
    DoIt.Commfig.set(@llm, value)
    message("Update llm configures successfully", :green)
  end
end
