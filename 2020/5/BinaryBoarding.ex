defmodule BinaryBoarding do
  def solve do
    get_input("input.txt")
    |> Enum.map(&(String.graphemes(&1)))
    |> Enum.map(&(seat_code_to_binary(&1)))
    |> Enum.map(&(parse_seat_code(&1)))
    |> Enum.sort()
    |> own_seat_code()
    |> show_output()
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

  def seat_code_to_binary(seat_code) do
    Enum.map(seat_code, &(elem(Map.fetch(binary_space_partitioning_type(), String.to_atom(&1)), 1)))
  end

  def binary_space_partitioning_type do
    %{"F": "0", "B": "1", "L": "0", "R": "1"}
  end

  def parse_seat_code(seat_code) do
    row = Enum.take(seat_code, 7) |> Enum.map(&(to_integer(&1))) |> binary_to_decimal()
    column = Enum.take(seat_code, -3) |> Enum.map(&(to_integer(&1))) |> binary_to_decimal()

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
  def sum_up list, acc do
    [head | tail] = list
    length = Enum.count list
    if head === 1 do
      sum_up tail, acc + (:math.pow(2, length - 1) |> round)
    else
      if head !== 0 do
          raise "Encountered a digit other than 0 or 1"
      else
          sum_up tail, acc
      end
    end
  end

  def to_integer(my_string) do
    case Integer.parse(my_string) do
      {number, _} -> number
      :error -> "It didn't work"
    end
  end
end
