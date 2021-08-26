defmodule LobbyLayout do
  def get_data do
    IOModule.get_input("24", "\r\n")
    |> Enum.map(&(parse_line(&1)))
  end

  def parse_line(line) do
    line
    |> String.graphemes()
    |> parse_tokens()
  end

  def parse_tokens([]), do: []
  def parse_tokens(line) do
    case line do
      ["n", "w" | tail] -> [:nw | parse_tokens(tail)]
      ["n", "e" | tail] -> [:ne | parse_tokens(tail)]
      ["e"      | tail] -> [:e  | parse_tokens(tail)]
      ["s", "e" | tail] -> [:se | parse_tokens(tail)]
      ["w"      | tail] -> [:w  | parse_tokens(tail)]
      ["s", "w" | tail] -> [:sw | parse_tokens(tail)]
    end
  end

  def part_one do
    get_data()
    |> Enum.map(&(coordinates(&1, {0.0, 0.0})))
    |> Enum.frequencies()
    |> Map.new(fn {k, v} -> {k, tile_color(v)} end)
    |> number_of_black_tiles_facing_up()
  end

  def coordinates([], acc), do: acc
  def coordinates(path, acc) do
    case path do
      [:nw | tail]  -> coordinates(tail, Enum.reduce([acc, {-0.5, 1.0}],  fn {a, b}, {x, y} -> {a + x, b + y} end))
      [:ne | tail]  -> coordinates(tail, Enum.reduce([acc, {0.5, 1.0}],   fn {a, b}, {x, y} -> {a + x, b + y} end))
      [:e  | tail]  -> coordinates(tail, Enum.reduce([acc, {1.0, 0.0}],   fn {a, b}, {x, y} -> {a + x, b + y} end))
      [:se | tail]  -> coordinates(tail, Enum.reduce([acc, {0.5, -1.0}],  fn {a, b}, {x, y} -> {a + x, b + y} end))
      [:w  | tail]  -> coordinates(tail, Enum.reduce([acc, {-1.0, 0.0}],  fn {a, b}, {x, y} -> {a + x, b + y} end))
      [:sw | tail]  -> coordinates(tail, Enum.reduce([acc, {-0.5, -1.0}], fn {a, b}, {x, y} -> {a + x, b + y} end))
    end
  end

  def tile_color(number_of_flips) do
    if rem(number_of_flips, 2) == 0 do :white else :black end
  end

  def number_of_black_tiles_facing_up(tiles_mapped_with_color) do
    tiles_mapped_with_color
    |> Map.values()
    |> Enum.frequencies()
    |> Map.get(:black)
  end

  def part_two do
    0
  end
end
