defmodule TobogganTrajectory do
  @no_day 3

  @tree "#"
  @slopes [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

  defp to_matrix(rows) do
    rows
    |> Enum.map(&String.graphemes(&1))
    |> Matrix.from_list()
  end

  def get_data() do
    @no_day
    |> IOModule.get_input()
    |> to_matrix()
  end

  defp gen_trajectory(slope, {row_max, col_max}) do
    slope
    |> List.wrap()
    |> Stream.cycle()
    |> Stream.scan(fn {x, y}, {acc_x, acc_y} -> {acc_x + x, acc_y + y} end)
    |> Stream.map(fn {x, y} -> {rem(x, col_max), y} end)
    |> Stream.take_while(fn {_, y} -> y < row_max end)
  end

  defp tree_encounters(trajectory, board) do
    trajectory
    |> Stream.map(fn {i, j} -> if board[j][i] == @tree, do: 1, else: 0 end)
    |> Stream.scan(&(&1 + &2))
    |> Stream.take(-1)
    |> Enum.to_list()
    |> hd()
  end

  defp do_slide(slide, board) do
    limits = Matrix.dimensions(board)

    slide
    |> gen_trajectory(limits)
    |> tree_encounters(board)
  end

  def part_one() do
    board = get_data()
    limits = Matrix.dimensions(board)

    @slopes
    |> Enum.at(1)
    |> do_slide(board)
  end

  def part_two() do
    board = get_data()
    limits = Matrix.dimensions(board)

    @slopes
    |> Enum.map(&do_slide(&1, board))
    |> Enum.reduce(&*/2)
  end
end
