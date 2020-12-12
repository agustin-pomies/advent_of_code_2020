defmodule EncodingError do
  def get_data do
    IOModule.get_input("9") |> Enum.map(&(Helper.to_integer(&1)))
  end

  def part_one() do
    get_data() |> advance(25)
  end

  def part_two do
    0
  end

  def advance(collection, quantity) do
    subcollection = Enum.take(collection, quantity + 1)
    subsubcollection = Enum.take(subcollection, quantity)
    number = List.last(subcollection)

    if check_sum(subsubcollection, number) do
      Enum.drop(collection, 1) |> advance(quantity)
    else
      number
    end
  end

  def check_sum(collection, number) do
    combinations(collection) |> Enum.any?(fn {a, b} -> a + b == number end)
  end
  
  def combinations(collection) do
    for x <- collection, y <- collection, x != y, do: {x, y}
  end
end
