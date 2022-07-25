defmodule ReportRepair do
  @no_day 1

  @checksum 2020
  @couple 2
  @triple 3

  def get_data do
    IOModule.get_input(@no_day)
    |> Enum.map(&String.to_integer(&1))
  end

  def part_one do
    get_data()
    |> combinations(@couple)
    |> check_sum()
    |> final_answer()
  end

  def part_two do
    get_data()
    |> combinations(@triple)
    |> check_sum()
    |> final_answer()
  end

  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []
  defp combinations([h|t], m) do
    (for l <- combinations(t, m-1), do: [h|l]) ++ combinations(t, m)
  end

  defp check_sum([]), do: nil
  defp check_sum([h|t]) do
    if Enum.reduce(h, 0, &+/2) == @checksum, do: h, else: check_sum(t)
  end

  def final_answer(collection), do: Enum.reduce(collection, 1, &*/2)
end
