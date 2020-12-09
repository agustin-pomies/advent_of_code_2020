defmodule ReportRepair do
  def get_data do
    IOModule.get_input("1") |> Enum.map(&Helper.to_integer(&1))
  end

  def part_one do
    get_data()
    |> combinations_1()
    |> check_sum()
    |> elem(1)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def part_two do
    get_data()
    |> combinations_2()
    |> check_sum()
    |> elem(1)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  defp combinations_1(collection) do
    for x <- collection, y <- collection, x != y, do: [x, y]
  end

  defp combinations_2(collection) do
    for x <- collection, y <- collection, z <- collection, x != y && y != z && x != z, do: [x, y, z]
  end

  defp check_sum([head | tail]) do
    if Enum.reduce(head, 0, fn x, acc -> x + acc end) == 2020,
      do: {:ok, head},
      else: check_sum(tail)
  end

  defp check_sum([]) do
    {:error, "No matching entries were found"}
  end
end
