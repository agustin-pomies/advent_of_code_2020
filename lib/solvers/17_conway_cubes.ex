defmodule ConwayCubes do
  def get_data do
    IOModule.get_input("17", "\n") |> parse_board()
  end

  def parse_board(rows) do
    rows = rows |> Enum.map(&String.graphemes(&1))
    number_of_rows = rows |> length()
    number_of_columns = rows |> hd() |> length()
    
    rows_range = 0..number_of_rows-1
    columns_range = 0..number_of_columns-1

    rows = Enum.map(rows, fn row -> Enum.map(row, fn symbol -> Map.fetch!(tile_type(), symbol) end) end)
    rows = Enum.zip(rows_range, rows)
    rows = Enum.map(rows, fn {row_index, row} -> {row_index, Enum.zip(columns_range, row)} end)

    board = Enum.reduce(
      rows,
      %{},
      fn {row_index, row}, acc -> 
        Map.merge(acc, Enum.reduce(
          row,
          %{},
          fn {column_index, element}, acc -> Map.merge(acc, %{{row_index, column_index, 0} => element}) end
        ))
      end
    )

    board
  end

  def tile_type do
    %{"." => :inactive, "#" => :active}
  end

  def part_one do
    get_data()
    |> boot_process(6)
    |> Enum.filter(fn {_coords, state} -> state == :active end)
    |> length()
  end

  def boot_process(board, 0), do: board
  def boot_process(board, cycles) do
    execute_cycle(board)
    |> boot_process(cycles - 1)
  end

  def execute_cycle(board) do
    active_neighbours = Enum.reduce(board, %{}, fn {coords, state}, acc -> if state == :active, do: update_neighbours(acc, neighbours(coords)), else: acc end)

    for {coords, neighbours} <- active_neighbours, into: %{}, do: {coords, new_state(board, coords, neighbours)}
  end

  def neighbours({a, b, c}) do
    for x <- a-1..a+1, y <- b-1..b+1, z <- c-1..c+1, {x, y, z} != {a, b, c}, do: {x, y, z}
  end

  def update_neighbours(neighbours_register, []), do: neighbours_register
  def update_neighbours(neighbours_register, [coord | coords]) do
    case Map.fetch(neighbours_register, coord) do
      {:ok, neighbours}  -> update_neighbours(Map.put(neighbours_register, coord, neighbours + 1), coords)
      :error             -> update_neighbours(Map.put(neighbours_register, coord, 1), coords)
    end
  end

  def new_state(board, coords, neighbours) do
    case Map.fetch(board, coords) do
      {:ok, :active}    -> if neighbours == 2 || neighbours == 3, do: :active, else: :inactive
      {:ok, :inactive}  -> if neighbours == 3, do: :active, else: :inactive
      :error            -> if neighbours == 3, do: :active, else: :inactive
    end
  end

  def part_two do
    0
  end
end
