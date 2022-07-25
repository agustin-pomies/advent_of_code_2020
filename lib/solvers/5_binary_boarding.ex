defmodule BinaryBoarding do
  def get_data do
    IOModule.get_input(5)
    |> Enum.map(&String.graphemes(&1))
    |> Enum.map(&seat_code_to_binary(&1))
    |> Enum.map(&parse_seat_code(&1))
  end

  def part_one do
    get_data() |> Enum.max()
  end

  def part_two do
    get_data() |> Enum.sort() |> own_seat_code()
  end

  def seat_code_to_binary(seat_code) do
    Enum.map(seat_code, &elem(Map.fetch(binary_space_partitioning_type(), String.to_atom(&1)), 1))
  end

  def binary_space_partitioning_type do
    %{F: "0", B: "1", L: "0", R: "1"}
  end

  def parse_seat_code(seat_code) do
    row = Enum.take(seat_code, 7) |> Enum.map(&Helper.to_integer(&1)) |> binary_to_decimal()
    column = Enum.take(seat_code, -3) |> Enum.map(&Helper.to_integer(&1)) |> binary_to_decimal()

    seat_id(row, column)
  end

  def seat_id(x, y) do
    x * 8 + y
  end

  def own_seat_code([first | [second | tail]]) do
    if second == first + 1, do: own_seat_code([second | tail]), else: first + 1
  end

  def binary_to_decimal(n) do
    sum_up(n, 0)
  end

  def sum_up([], acc), do: acc

  def sum_up(list, acc) do
    [head | tail] = list
    length = Enum.count(list)

    if head === 1 do
      sum_up(tail, acc + (:math.pow(2, length - 1) |> round))
    else
      if head !== 0 do
        raise "Encountered a digit other than 0 or 1"
      else
        sum_up(tail, acc)
      end
    end
  end
end
