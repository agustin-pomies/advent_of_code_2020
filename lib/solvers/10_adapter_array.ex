defmodule AdapterArray do
  def get_data do
    IOModule.get_input("10") |> Enum.map(&(Helper.to_integer(&1)))
  end

  def part_one() do
    collection = get_data()
    device_joltage_adapter = Enum.max(collection) + 3

    [0 | [device_joltage_adapter | collection]]
    |> Enum.sort()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
    |> Enum.frequencies_by(&Function.identity/1)
    |> Map.values()
    |> Enum.reduce(1, &Kernel.*/2)
  end

  def part_two do
    0
  end
end
