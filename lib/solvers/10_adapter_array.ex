defmodule AdapterArray do
  use Memoize

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
    collection = get_data()
    device_joltage_adapter = Enum.max(collection) + 3

    adapters = [0 | [device_joltage_adapter | collection]] |> Enum.sort(&(&1 >= &2))
    count_path(adapters)    
  end

  def count_path([adapter | tail]) do
    case tail do
      []  -> 1
      _   -> auxiliar([adapter | tail])
    end
  end

  defmemo auxiliar([adapter | tail]) do
    Enum.take(tail, 3)
    |> Enum.filter(fn elem -> adapter - elem <= 3 end)
    |> Enum.map(fn previous_adapter -> {previous_adapter, Enum.drop_while(tail, fn elem -> elem != previous_adapter end)} end)
    |> Enum.reduce(0, fn {_previous_adapter, subsubcollection}, acc -> acc + count_path(subsubcollection) end)
  end
end
