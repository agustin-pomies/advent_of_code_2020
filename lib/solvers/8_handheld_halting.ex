defmodule HandheldHalting do
  def get_data do
    IOModule.get_input("8") |> parse_input()
  end

  def part_one() do
    get_data() |> run(0, 1)
  end

  def part_two do
    0
  end

  def parse_input(data) do
    1..length(data)
    |> Stream.zip(data)
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> [instruction, change] = String.split(v, " "); {k, {String.to_atom(instruction), Helper.to_integer(change)}} end)
    |> Enum.into(%{})
  end

  def run(program, acc, line_number) do
    {instruction, new_program} = Map.pop(program, line_number)

    case instruction do
      {:nop, _value}  -> run(new_program, acc, line_number + 1)
      {:acc, value}   -> run(new_program, acc + value, line_number + 1)
      {:jmp, offset}  -> run(new_program, acc, line_number + offset)
      _               -> acc
    end
  end
end
