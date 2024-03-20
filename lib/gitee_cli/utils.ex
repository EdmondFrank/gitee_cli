defmodule GiteeCli.Utils do
  alias Unicode.EastAsianWidth, as: Width

  def message(msg, color) when is_atom(color) do
    msg
    |> Owl.Data.tag(color)
    |> Owl.IO.puts()
  end

  def string_width(string) do
    width =
      string
      |> String.to_charlist()
      |> Enum.map(&Width.east_asian_width_category(&1))
      |> Enum.reduce(0, fn width, acc -> if(width == :w, do: acc + 2, else: acc + 1) end)
    width
  end

  def truncate(string, limit \\ 15) do
    Owl.Data.truncate(string, limit)
    |> IO.iodata_to_binary()
  end

  def try_convert_value_of_map_to_string(map, mappings \\ %{}) do
    Map.new(map, fn {key, value} ->
      cond  do
        is_map(map[key]) ->
          first_value =
            Enum.map(mappings[key], &(get_in(map[key], &1)))
            |> Enum.filter(& &1)
            |> List.first
          {key, to_string(first_value)}
        true ->
          {key, to_string(value)}
      end
    end)
  end
end
