defmodule JurassicJigsaw do
  def get_data do
    IOModule.get_input(20, "\n\n")
    |> Enum.map(&(parse_tile(&1)))
    |> Enum.into(%{})
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

  def test do
    tiles_with_metadata =
      get_data()
      |> Enum.map(fn {tile_number, tile_pattern} -> %{tile_number => %{pattern: tile_pattern, transformed: false, neighbours: %{up: nil, down: nil, left: nil, right: nil}}} end)
      |> Enum.reduce(fn elem, acc -> Map.merge(acc, elem) end)
    
    tiles = tiles_with_metadata
    borders_to_assemble = for id_1 <- Map.keys(tiles), id_2 <- Map.keys(tiles), id_1 < id_2, do: {id_1, id_2}

    assemble_image(tiles_with_metadata, borders_to_assemble)
    |> IO.inspect()
  end

  def assemble_image(tiles_with_metadata, []), do: tiles_with_metadata
  def assemble_image(tiles_with_metadata, [{id_1, id_2} = borders_pair | ids]) do
    tile_1 = Map.fetch!(tiles_with_metadata, id_1) |> Map.fetch!(:pattern)
    tile_2 = Map.fetch!(tiles_with_metadata, id_2) |> Map.fetch!(:pattern)

    case align_tiles(tile_1, tile_2) do
      :no_match -> assemble_image(tiles_with_metadata, ids)
      match     -> assemble_image(update_tiles(tiles_with_metadata, borders_pair, match), ids)
    end
  end

  def align_tiles(tile_1, tile_2) do
    possibilities = for x <- borders(tile_1), y <- borders(tile_2), do: {x, y}

    results =
      possibilities
      |> Enum.map(&(borders_match?(&1)))
      |> Enum.filter(fn elem -> elem != nil end)

    case results do
      []     -> :no_match
      [elem] -> elem
    end
  end

  def borders(pattern) do
    %{
      up: List.first(pattern),
      right: Enum.map(pattern, &(List.last(&1))),
      down: List.last(pattern) |> Enum.reverse(),
      left: Enum.map(pattern, &(List.first(&1))) |> Enum.reverse(),
    }
  end

  def update_tiles(tiles_with_metadata, {id_1, id_2}, {direction_1, direction_2, orientation}) do
    tile_1_metadata = Map.fetch!(tiles_with_metadata, id_1)
    tile_2_metadata = Map.fetch!(tiles_with_metadata, id_2)
    transformation_required? = direction_1 != opposite_direction(direction_2) || orientation == "flipped"
    tile_1_old_pattern = Map.fetch!(tile_1_metadata, :pattern)

    tile_1_new_metadata =
      if transformation_required? do
        tile_1_new_pattern =
          tile_1_old_pattern
          |> apply_rotation({direction_1, direction_2})
          |> apply_flip({opposite_direction(direction_2), orientation})

        tile_1_metadata
        |> Map.put(:pattern, tile_1_new_pattern)
        |> Map.put(:transformed, true)
      else
        tile_1_metadata
      end

    tile_1_new_neighbours =
      tile_1_metadata
      |> Map.fetch!(:neighbours)
      |> Map.put(opposite_direction(direction_2), id_2)
    
    tile_1_new_metadata = Map.put(tile_1_new_metadata, :neighbours, tile_1_new_neighbours)

    tile_2_new_neighbours =
      tile_2_metadata
      |> Map.fetch!(:neighbours)
      |> Map.put(direction_2, id_1)

    tile_2_new_metadata = Map.put(tile_2_metadata, :neighbours, tile_2_new_neighbours)

    tiles_with_metadata
    |> Map.put(id_1, tile_1_new_metadata)
    |> Map.put(id_2, tile_2_new_metadata)
  end

  def part_one do
    tiles = get_data() |> filter_borders()
    borders_to_assemble = for id_1 <- Map.keys(tiles), id_2 <- Map.keys(tiles), id_1 < id_2, do: {id_1, id_2}

    determine_tile_relations(tiles, borders_to_assemble, [])
    |> IO.inspect()
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
      down: List.last(pattern) |> Enum.reverse(),
      left: Enum.map(pattern, &(List.first(&1))) |> Enum.reverse(),
    }
  end

  def determine_borders(tiles_aligned) do
    tiles_aligned
    |> Enum.map(fn {border_1, border_2, _flipped} -> [elem(border_1, 0), elem(border_2, 0)] end)
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_id, count} -> count == 2 end)
    |> Enum.map(&(elem(&1, 0)))
  end

  def determine_tile_relations(_, [], board), do: board
  def determine_tile_relations(tiles, [{id_1, id_2} | ids], board) do
    tile_1 = Map.fetch!(tiles, id_1) |> Map.to_list()
    tile_2 = Map.fetch!(tiles, id_2) |> Map.to_list()

    case align_tiles(tile_1, tile_2) do
      :no_match                               -> determine_tile_relations(tiles, ids, board)
      {direction_1, direction_2, "original"}  -> determine_tile_relations(tiles, ids, [{{id_1, direction_1}, {id_2, direction_2}, "original"}| board])
      {direction_1, direction_2, "flipped"}   -> determine_tile_relations(tiles, ids, [{{id_1, direction_1}, {id_2, direction_2}, "flipped"}| board])
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
      same_border?(border_1, Enum.reverse(border_2))  -> {side_1, side_2, "original"}
      same_border?(border_1, border_2)                -> {side_1, side_2, "flipped"}
      true                                            -> nil
    end
  end

  def same_border?([char | border_1], [char | border_2]), do: same_border?(border_1, border_2)
  def same_border?([], []), do: true
  def same_border?(_, _), do: false

  def apply_rotation(pattern, {direction_1, direction_2}) do
    if direction_1 != opposite_direction(direction_2) do
      pattern
      |> Enum.map(&(Enum.reverse(&1)))
      |> transpose()
      |> apply_rotation({next_direction(direction_1), direction_2})
    else
      pattern
    end
  end

  def apply_flip(pattern, {_, "original"}), do: pattern
  def apply_flip(pattern, {:down, "flipped"}) do
    Enum.map(pattern, &(Enum.reverse(&1)))
  end
  def apply_flip(pattern, {:up, "flipped"}) do
    Enum.map(pattern, &(Enum.reverse(&1)))
  end
  def apply_flip(pattern, {:right, "flipped"}) do
    Enum.reverse(pattern)
  end
  def apply_flip(pattern, {:left, "flipped"}) do
    Enum.reverse(pattern)
  end

  def transpose([]), do: []
  def transpose([[]|_]), do: []
  def transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

  # def tile_orientations(tile) do
  #   tile_rotations(tile) ++ tile_rotations(tile_flip(tile))
  # end

  # def tile_rotations(%{id: id, pattern: pattern}) do
  #   directions = directions()

  #   0..3
  #   |> Enum.map(fn offset -> Enum.slice(directions, -offset, offset) ++ Enum.slice(directions, 0, length(directions) - offset)  end)
  #   |> Enum.map(fn permutation -> Enum.map(permutation, &(Map.fetch!(pattern, &1))) end)
  #   |> Enum.map(&(Enum.zip(directions, &1)))
  #   |> Enum.map(&(Map.new(&1)))
  #   |> Enum.map(fn permutation -> %{id => permutation} end)
  # end

  # def tile_flip(%{id: id, pattern: %{right: right, left: left, up: up, down: down}}) do
  #   # horizontal axis
  #   %{
  #     id => %{
  #       right: Enum.reverse(right),
  #       left: Enum.reverse(left),
  #       up: down,
  #       down: up
  #     }
  #   }
  # end

  # def directions do
  #   [:up, :right, :down, :left]
  # end

  def next_direction(direction) do
    case direction do
      :up    -> :right
      :right -> :down
      :down  -> :left
      :left  -> :up
    end
  end

  def opposite_direction(direction) do
    case direction do
      :up     -> :down
      :left   -> :right
      :down   -> :up
      :right  -> :left
    end
  end

  def part_two do
    tiles = get_data()

    borders = tiles |> filter_borders()
    borders_to_assemble = for id_1 <- Map.keys(borders), id_2 <- Map.keys(borders), id_1 < id_2, do: {id_1, id_2}

    borders
    |> determine_tile_relations(borders_to_assemble, [])
    |> assemble_board()
    0
  end

  def assemble_board([{tile_1, tile_2, orientation} | tiles]) do
    {id_1, direction_1} = tile_1
    {id_2, direction_2} = tile_2
  end

  def delete_borders(tile) do
    tile
    |> Enum.drop(1)
    |> Enum.drop(-1)
    |> Enum.map(&(Enum.drop(&1, 1)))
    |> Enum.map(&(Enum.drop(&1, -1)))
  end
end
