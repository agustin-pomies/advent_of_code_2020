defmodule JurassicJigsaw do
  def get_data do
    IOModule.get_input("20", "\n\n")
    |> Enum.map(&(parse_tile(&1)))
  end

  def parse_tile(string) do
    string
    |> String.split(":\n", trim: true)
    |> (fn ["Tile " <> id_number, string_pattern] -> %{String.to_integer(id_number) => parse_pattern(string_pattern)} end).()
    |> Enum.reduce(fn elem, acc -> Map.merge(acc, elem) end)
  end

  def parse_pattern(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.graphemes(&1)))
  end

  def part_one do
    tiles = get_data() |> filter_borders()
    borders_to_assemble = for id_1 <- Map.keys(tiles), id_2 <- Map.keys(tiles), id_1 < id_2, do: {id_1, id_2}

    reassemble_image(tiles, borders_to_assemble, [])
    |> determine_borders()
    |> Enum.reduce(&Kernel.*/2)
  end

  def filter_borders(tiles) do
    for {id, pattern} <- tiles, into: %{}, do: {id, build_borders(pattern)}
  end

  def build_borders(pattern) do
    %{
      up: List.first(pattern),
      right: Enum.map(pattern, &(List.last(&1))),
      down: List.last(pattern),
      left: Enum.map(pattern, &(List.first(&1))),
    }
  end

  def determine_borders(tiles_aligned) do
    tiles_aligned
    |> Enum.map(fn {border_1, border_2} -> [elem(border_1, 0), elem(border_2, 0)] end)
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_id, count} -> count == 2 end)
    |> Enum.map(&(elem(&1, 0)))
  end

  def reassemble_image(_, [], board), do: board
  def reassemble_image(tiles, [{id_1, id_2} | ids], board) do
    tile_1 = Map.fetch!(tiles, id_1) |> Map.to_list()
    tile_2 = Map.fetch!(tiles, id_2) |> Map.to_list()

    case align_tiles(tile_1, tile_2) do
      :no_match                             -> reassemble_image(tiles, ids, board)
      {direction_1, direction_2}            -> reassemble_image(tiles, ids, [{{id_1, direction_1}, {id_2, direction_2}}| board])
      {direction_1, direction_2, "flipped"} -> reassemble_image(tiles, ids, [{{id_1, direction_1}, {id_2, direction_2, "flipped"}}| board])
    end
  end

  def align_tiles(tile_1, tile_2) do
    possibilities = for x <- tile_1, y <- tile_2, do: {x, y}

    results =
      possibilities
      |> Enum.map(&(borders_match?(&1)))
      |> Enum.filter(fn elem -> elem != nil end)

    case results do
      []     -> :no_match
      [elem] -> elem
    end
  end

  def borders_match?({{side_1, border_1}, {side_2, border_2}}) do
    cond do
      same_border?(border_1, border_2)                -> {side_1, side_2}
      same_border?(border_1, Enum.reverse(border_2))  -> {side_1, side_2, "flipped"}
      true                                            -> nil
    end
  end

  def same_border?([char | border_1], [char | border_2]), do: same_border?(border_1, border_2)
  def same_border?([], []), do: true
  def same_border?(_, _), do: false

  def part_two do
    0
  end
end
