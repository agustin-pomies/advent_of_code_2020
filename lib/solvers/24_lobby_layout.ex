defmodule LobbyLayout do
  def get_data do
    IOModule.get_input(24, "\r\n")
    |> Enum.map(&parse_line(&1))
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
      ["e" | tail] -> [:e | parse_tokens(tail)]
      ["s", "e" | tail] -> [:se | parse_tokens(tail)]
      ["w" | tail] -> [:w | parse_tokens(tail)]
      ["s", "w" | tail] -> [:sw | parse_tokens(tail)]
    end
  end

  def part_one do
    get_data()
    |> Enum.map(&coordinates(&1, {0.0, 0.0}))
    |> Enum.frequencies()
    |> Map.new(fn {k, v} -> {k, tile_color(v)} end)
    |> IO.inspect()
    |> number_of_black_tiles_facing_up()
  end

  def coordinates([], acc), do: acc

  def coordinates(path, acc) do
    case path do
      [:nw | tail] ->
        coordinates(
          tail,
          Enum.reduce([acc, {-0.5, 1.0}], fn {a, b}, {x, y} -> {a + x, b + y} end)
        )

      [:ne | tail] ->
        coordinates(tail, Enum.reduce([acc, {0.5, 1.0}], fn {a, b}, {x, y} -> {a + x, b + y} end))

      [:e | tail] ->
        coordinates(tail, Enum.reduce([acc, {1.0, 0.0}], fn {a, b}, {x, y} -> {a + x, b + y} end))

      [:se | tail] ->
        coordinates(
          tail,
          Enum.reduce([acc, {0.5, -1.0}], fn {a, b}, {x, y} -> {a + x, b + y} end)
        )

      [:w | tail] ->
        coordinates(
          tail,
          Enum.reduce([acc, {-1.0, 0.0}], fn {a, b}, {x, y} -> {a + x, b + y} end)
        )

      [:sw | tail] ->
        coordinates(
          tail,
          Enum.reduce([acc, {-0.5, -1.0}], fn {a, b}, {x, y} -> {a + x, b + y} end)
        )
    end
  end

  def tile_color(number_of_flips) do
    if rem(number_of_flips, 2) == 0 do
      :white
    else
      :black
    end
  end

  def number_of_black_tiles_facing_up(tiles_mapped_with_color) do
    tiles_mapped_with_color
    |> Map.values()
    |> Enum.frequencies()
    |> Map.get(:black)
  end

  def part_two do
    get_data()
    |> Enum.map(&coordinates(&1, {0.0, 0.0}))
    |> Enum.frequencies()
    |> Map.new(fn {k, v} -> {k, tile_color(v)} end)
    |> Enum.filter(fn {_, v} -> v == :black end)
    |> Map.new()
    |> advance_day(0)
    |> number_of_black_tiles_facing_up()
  end

  def advance_day(floor, 100), do: floor

  def advance_day(floor, counter) do
    black_tiles = Enum.filter(floor, fn {_, v} -> v == :black end)

    default_black_tiles =
      black_tiles
      |> Enum.reduce(%{}, fn {coordinates, _}, acc -> Map.put(acc, coordinates, 0) end)
      |> Map.new()

    tiles_with_black_neighbours =
      black_tiles
      |> Enum.reduce([], fn {k, _}, acc -> neighbors(k) ++ acc end)
      |> Enum.frequencies()

    tiles_to_examine = Map.merge(default_black_tiles, tiles_with_black_neighbours)

    new_floor =
      floor
      |> tiles_to_flip(tiles_to_examine)
      |> floor_after_flip(floor)

    IO.puts("Day #{counter + 1}: #{number_of_black_tiles_facing_up(new_floor)}")

    advance_day(new_floor, counter + 1)
  end

  def neighbors({a, b}) do
    for x <- [a - 1.0, a - 0.5, a + 0.5, a + 1.0],
        y <- [b - 1.0, b, b + 1.0],
        (abs(y - b) == 0.0 || abs(x - a) == 0.5) && (abs(y - b) != 0.0 || abs(x - a) == 1.0),
        do: {x, y}
  end

  def tiles_to_flip(floor, tiles_to_examine) do
    tiles_to_examine
    |> Enum.filter(fn {coordinates, number_of_neighbours} ->
      need_state_change?(Map.get(floor, coordinates, :white), number_of_neighbours)
    end)
    |> Enum.map(&elem(&1, 0))
  end

  def need_state_change?(current_color, number_of_neighbours) do
    case current_color do
      :black -> number_of_neighbours == 0 || number_of_neighbours > 2
      :white -> number_of_neighbours == 2
    end
  end

  def floor_after_flip(tiles_to_flip, current_floor) do
    Enum.reduce(tiles_to_flip, current_floor, fn elem, acc ->
      Map.update(acc, elem, :black, &opposite_color(&1))
    end)
  end

  def opposite_color(:black), do: :white
  def opposite_color(:white), do: :black
end
