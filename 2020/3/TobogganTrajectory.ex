defmodule TobogganTrajectory do
  def initial_square do
    {0, 0}
  end

  def slopes do
    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
  end

  def solve do
    board = get_input("input.txt") |> parse_board()
    tree_encounters = Enum.map(slopes(), &(tree_encounters(board, &1)))

    IO.inspect(tree_encounters)

    output = Enum.reduce(tree_encounters, 1, fn x, acc -> x * acc end)
    show_output(output)
  end

  def tree_encounters(board, movement) do
    begin_trajectory(board, initial_square(), movement)
  end

  def get_input(file_name) do
    case File.read(file_name) do
      {:ok, file}      -> String.split(file, "\n", trim: true)
      {:error, reason} -> reason
    end
  end

  def show_output(output) do
    IO.puts("The answer is #{output}")
  end

  def parse_board(rows) do
    rows
    |> Enum.map(&(String.graphemes(&1)))
    |> Enum.map(fn row -> Enum.map(row, fn symbol -> elem(Map.fetch(tile_type(), symbol), 1) end) end)
  end

  def tile_type do
    %{"." => :square, "#" => :tree}
  end

  def char_type do
    %{square: ".", tree: "#"}
  end

  def begin_trajectory(board, {x, y}, movement, tree_encounters \\ 0) do
    initialized_board = move_to_initial_square(board, {x, y})
    new_tree_encounters = new_tree_encounters(initialized_board, tree_encounters)
    result = travel_through_board(movement, initialized_board, new_tree_encounters)

    case result do
      {:halt, result_tree_encounters}                          -> result_tree_encounters
      {:repeat_board, {new_x, new_y}, result_tree_encounters}  -> begin_trajectory(board, {new_x, length(board) - new_y}, movement, result_tree_encounters)
    end
  end

  def move_to_initial_square(board, {x, y}) do
    board
    |> Enum.drop(y)
    |> Enum.map(&(Enum.drop(&1, x)))
  end

  def travel_through_board(movement, [_ | [_ | _]] = board, tree_encounters) do
    case apply_movement(board, movement) do
      {:travel, new_board}            -> travel_through_board(movement, new_board, new_tree_encounters(new_board, tree_encounters))
      {:change_board, initial_square} -> {:repeat_board, initial_square, tree_encounters}
      {:halt, final_board}            -> {:halt, new_tree_encounters(final_board, tree_encounters) }
    end
  end

  def travel_through_board(_, [_ | _], tree_encounters) do
    {:halt, tree_encounters}
  end

  def apply_movement(board, movement = {x, y}) do
    cond do
      (length(board) > y) && (length(hd(board)) > x)  -> travel(board, movement)
      length(hd(board)) <= x                          -> change_board(board, movement)
      length(board) <= y                              -> check_final_tile(board, movement)
    end
  end

  def travel(board, {x, y}) do
    new_board = board
                |> Enum.drop(y)
                |> Enum.map(&(Enum.drop(&1, x)))

    {:travel, new_board}
  end

  def change_board(board = [row | _], {x, y}) do
    initial_square = {x - length(row), length(board) - y}

    {:change_board, initial_square}
  end

  def check_final_tile(board, {x, _}) do
    final_row = board
                |> List.last()
                |> Enum.drop(x)

    {:halt, [final_row]}
  end

  def new_tree_encounters(board, tree_encounters \\ 0) do
    if tree_encountered?(board), do: tree_encounters + 1, else: tree_encounters
  end

  def tree_encountered?(board) do
    tile = board
           |> hd()
           |> hd()
    
    tile == :tree
  end

  # Debug Tools

  def print_board(board) do
    board
    |> board_to_chars()
    |> IO.puts
  end

  def board_to_chars(board) do
    Enum.join(Enum.map(board, &(row_to_chars(&1))), "\n")
  end

  def row_to_chars(row) do
    Enum.join(Enum.map(row, &(elem(Map.fetch(char_type(), &1), 1))))
  end
end
