defmodule GiteeCli.Utils do
  def message(msg, color) when is_atom(color) do
    msg
    |> Owl.Data.tag(color)
    |> Owl.IO.puts()
  end
end
