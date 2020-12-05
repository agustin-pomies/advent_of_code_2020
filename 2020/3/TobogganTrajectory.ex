defmodule TobogganTrajectory do
  def initial_square do
    {0, 0}
  end

  def movement do
    {3, 1}
  end

  def solve do
    get_input()
    |> parse_board()
    |> begin_trajectory(initial_square())
    |> show_output()
  end

  def get_input do
    case File.read("input.txt") do
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

  def begin_trajectory(board, {x, y}, tree_encounters \\ 0) do
    initialized_board = move_to_initial_square(board, {x, y})
    new_tree_encounters = new_tree_encounters(initialized_board, tree_encounters)
    result = travel_through_board(initialized_board, new_tree_encounters)

    case result do
      {:halt, tree_encounters} -> tree_encounters
      {:repeat_board, {new_x, new_y}, tree_encounters} -> begin_trajectory(board, {new_x, length(board) - new_y}, tree_encounters)
    end
  end

  def move_to_initial_square(board, {x, y}) do
    board
    |> Enum.drop(y)
    |> Enum.map(&(Enum.drop(&1, x)))
  end

  def travel_through_board([_ | [_ | _]] = board, tree_encounters) do
    case apply_movement(board, movement()) do
      {:travel, new_board} -> travel_through_board(new_board, new_tree_encounters(new_board, tree_encounters))
      {:change_board, initial_square} -> {:repeat_board, initial_square, tree_encounters}
    end
  end

  def travel_through_board([_ | _], tree_encounters) do
    {:halt, tree_encounters}
  end

  def apply_movement(board, {x, y}) do
    if length(hd(board)) > x, do: travel(board, {x, y}), else: change_board(board, x)
  end

  def travel(board, {x, y}) do
    new_board = board
                |> Enum.drop(y)
                |> Enum.map(&(Enum.drop(&1, x)))

    {:travel, new_board}
  end

  def change_board(board = [row | _], horizontal_movement) do
    initial_square = {horizontal_movement - length(row), length(board) - 1}

    {:change_board, initial_square}
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
