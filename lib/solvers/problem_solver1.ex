defmodule ProblemSolver1 do
  def solve(number) do
    IOModule.get_input("1")
    |> Enum.map(&(Helper.convert_to_integer(&1)))
    |> combinations(number)
    |> check_sum()
    |> elem(1)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
    |> IOModule.show_output()
  end

  def combinations([head | tail], number) do
    acc = for x <- tail, do: [head, x]
    acc ++ combinations(tail, number)
  end

  def combinations([], number) do
    []
  end

  # defp combinations(collection) do
  #   for x <- collection, y <- collection, x != y, do: [x, y]
  # end

  defp check_sum([head | tail]) do
    if Enum.reduce(head, 0, fn x, acc -> x + acc end) == 2020, do: {:ok, head}, else: check_sum(tail)
  end

  defp check_sum([]) do
    {:error, "No matching entries were found"}
  end
end
