defmodule SeatingSystem do
  def get_data do
    IOModule.get_input(11) |> parse_board()
  end

  def part_one do
    get_data()
    |> reach_stable_configuration(&consecutive_seats/2)
    |> Map.values()
    |> Enum.filter(&(&1 == :busy))
    |> length()
  end

  def part_two do
    get_data()
    |> reach_stable_configuration(&change_state_using_visible_seats/2)
    |> Map.values()
    |> Enum.filter(&(&1 == :busy))
    |> length()
  end

  def parse_board(rows) do
    rows = rows |> Enum.map(&String.graphemes(&1))
    number_of_rows = rows |> length()
    number_of_columns = rows |> hd() |> length()

    rows_range = 0..(number_of_rows - 1)
    columns_range = 0..(number_of_columns - 1)

    rows =
      Enum.map(rows, fn row -> Enum.map(row, fn symbol -> Map.fetch!(tile_type(), symbol) end) end)

    rows = Enum.zip(rows_range, rows)
    rows = Enum.map(rows, fn {row_index, row} -> {row_index, Enum.zip(columns_range, row)} end)

    board =
      Enum.reduce(
        rows,
        %{},
        fn {row_index, row}, acc ->
          Map.merge(
            acc,
            Enum.reduce(
              row,
              %{},
              fn {column_index, element}, acc ->
                Map.merge(acc, %{{row_index, column_index} => element})
              end
            )
          )
        end
      )

    {board, {number_of_rows, number_of_columns}}
  end

  def tile_type do
    %{"." => :floor, "L" => :empty, "#" => :busy}
  end

  def reach_stable_configuration({board, _dimensions} = metaboard, new_seat) do
    new_metaboard = new_generation(metaboard, new_seat)
    {new_board, _dimensions} = new_metaboard

    if Map.equal?(board, new_board),
      do: board,
      else: reach_stable_configuration(new_metaboard, new_seat)
  end

  def new_generation({board, dimensions} = metaboard, new_seat) do
    new_board =
      Enum.map(board, fn {coord, seat_state} ->
        {coord, new_seat.(metaboard, {coord, seat_state})}
      end)
      |> Map.new()

    {new_board, dimensions}
  end

  def consecutive_seats(metaboard, {coord, seat_state}) do
    case seat_state do
      :floor ->
        :floor

      :empty ->
        if neighbors(metaboard, coord) |> Enum.all?(fn elem -> elem != :busy end),
          do: :busy,
          else: :empty

      :busy ->
        if neighbors(metaboard, coord) |> Enum.filter(&(&1 == :busy)) |> length() |> Kernel.>=(4),
          do: :empty,
          else: :busy
    end
  end

  def change_state_using_visible_seats(metaboard, {coord, seat_state}) do
    case seat_state do
      :floor ->
        :floor

      :empty ->
        if visible_seats(metaboard, coord) |> Enum.all?(fn elem -> elem != :busy end),
          do: :busy,
          else: :empty

      :busy ->
        if visible_seats(metaboard, coord)
           |> Enum.filter(&(&1 == :busy))
           |> length()
           |> Kernel.>=(5),
           do: :empty,
           else: :busy
    end
  end

  def neighbors({board, dimensions}, {a, b}) do
    coordinates =
      for x <- (a - 1)..(a + 1),
          y <- (b - 1)..(b + 1),
          x != a || y != b,
          in_range({x, y}, dimensions),
          do: {x, y}

    Enum.map(coordinates, fn coord -> Map.fetch!(board, coord) end)
  end

  def visible_seats(metaboard, origin) do
    directions = for x <- -1..1, y <- -1..1, x != 0 || y != 0, do: {x, y}

    Enum.map(directions, fn direction -> travel_while(metaboard, origin, direction) end)
  end

  def travel_while({board, dimensions} = metaboard, {a, b}, {c, d} = movement) do
    new_coordinates = {a + c, b + d}

    if in_range(new_coordinates, dimensions) do
      case Map.fetch!(board, new_coordinates) do
        :floor -> travel_while(metaboard, new_coordinates, movement)
        seat_state -> seat_state
      end
    else
      :floor
    end
  end

  def in_range({x, y}, {max_x, max_y}) do
    0 <= x && x < max_x && 0 <= y && y < max_y
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
    |> Enum.map(fn row -> Enum.map(row, &elem(&1, 1)) end)
  end

  def board_to_chars(board) do
    Enum.join(Enum.map(board, &row_to_chars(&1)), "\n")
  end

  def row_to_chars(row) do
    Enum.join(Enum.map(row, &elem(Map.fetch(char_type(), &1), 1)))
  end
end
