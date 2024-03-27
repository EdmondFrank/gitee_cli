defmodule GiteeCli.AttachFiles.Upload do
  use DoIt.Command,
    description: "Upload an attach file"

  import GiteeCli.Utils, only: [message: 2]

  option(:clipboard, :boolean, "Capture from clipboard and upload", alias: :c)

  def run(_args, params, %{config: %{"cookie" => cookie, "default_ent_id" => ent_id}}) do
    upload(:cookie, cookie, ent_id, params)
  end

  def run(_args, params, %{config: %{"access_token" => token, "default_ent_id" => ent_id}}) do
    upload(:access_token, token, ent_id, params)
  end

  def run(_args, _opts, context) do
    help(context)
  end

  def upload(auth, value, ent_id, %{clipboard: true}) do
    client = GiteeCat.Client.new(%{auth => value})
      case Clipboard.paste() do
        nil ->
          message("Error: failed to recognize clipboard image.", :red)
          exit({:shutdown, 1})
        data ->
          case GiteeCat.AttachFiles.upload_with_base64(client, ent_id, %{base64: "data:image/png;base64,#{:base64.encode(data)}"}) do
            {201, %{"file" => %{"url" => url}}, _resp} ->
              IO.puts(url)
            {_, reason, _response} ->
              message("Error: #{inspect(reason)}.", :red)
              exit({:shutdown, 1})
          end
      end
  end
end
