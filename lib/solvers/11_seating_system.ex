defmodule SeatingSystem do
  def get_data do
    IOModule.get_input("11") |> parse_board()
  end

  def part_one do
    get_data()
    |> reach_stable_configuration()
    |> Map.values()
    |> Enum.filter(&(&1 == :busy))
    |> length()
  end

  def part_two do
    0
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
          fn {column_index, element}, acc -> Map.merge(acc, %{{row_index, column_index} => element}) end
        ))
      end
    )

    {board, {number_of_rows, number_of_columns}}
  end

  def tile_type do
    %{"." => :floor, "L" => :empty, "#" => :busy}
  end

  def reach_stable_configuration({board, _dimensions} = metaboard) do
    new_metaboard = new_generation(metaboard)
    {new_board, _dimensions} = new_metaboard 

    if Map.equal?(board, new_board), do: board, else: reach_stable_configuration(new_metaboard)
  end

  def new_generation({board, dimensions} = metaboard) do
    new_board =
      Enum.map(board, fn {coord, seat_state} -> {coord, new_seat(metaboard, {coord, seat_state})} end)
      |> Map.new

    {new_board, dimensions}
  end

  def new_seat(metaboard, {coord, seat_state}) do
    case seat_state do
      :floor  -> :floor
      :empty  -> if neighbors(metaboard, coord) |> Enum.all?(fn elem -> elem != :busy end), do: :busy, else: :empty
      :busy   -> if neighbors(metaboard, coord) |> Enum.filter(&(&1 == :busy)) |> length() |> Kernel.>=(4), do: :empty, else: :busy
    end
  end

  def neighbors({board, dimensions}, {a, b}) do
    coordinates = for x <- a-1..a+1, y <- b-1..b+1, x != a || y != b, x >= 0 && x < elem(dimensions, 0), y >= 0 && y < elem(dimensions, 1), do: {x, y}

    Enum.map(coordinates, fn coord -> Map.fetch!(board, coord) end)
  end

  # Debugging tools
  def char_type do
    %{floor: ".", empty: "L", busy: "#"}
  end

  def print_board({board, dimensions}) do
    board |> board_to_matrix() |> board_to_chars() |> IO.puts()
    IO.puts("\n")

    {board, dimensions}
  end

  def board_to_matrix(board) do
    board
    |> Map.to_list()
    |> Enum.group_by(fn {coord, _seat_state} -> elem(coord, 0) end)
    |> Map.values()
    |> Enum.map(fn row -> Enum.sort_by(row, fn {coord, _seat_state} -> elem(coord, 1) end) end)
    |> Enum.map(fn row -> Enum.map(row, &(elem(&1, 1))) end)
  end

  def board_to_chars(board) do
    Enum.join(Enum.map(board, &row_to_chars(&1)), "\n")
  end

  def row_to_chars(row) do
    Enum.join(Enum.map(row, &elem(Map.fetch(char_type(), &1), 1)))
  end
end
