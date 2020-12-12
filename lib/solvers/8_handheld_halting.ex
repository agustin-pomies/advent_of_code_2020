defmodule HandheldHalting do
  def get_data do
    IOModule.get_input("8") |> parse_input()
  end

  def part_one() do
    get_data() |> run(0, 1) |> elem(1)
  end

  def part_two do
    get_data() |> run_alternatives(0, 1) |> elem(1)
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
      _               -> {line_number, acc}
    end
  end

  def run_instruction(program, acc, line_number) do
    {instruction, new_program} = Map.pop(program, line_number)

    case instruction do
      {:nop, _value}  -> run_alternatives(new_program, acc, line_number + 1)
      {:acc, value}   -> run_alternatives(new_program, acc + value, line_number + 1)
      {:jmp, offset}  -> run_alternatives(new_program, acc, line_number + offset)
      _               -> {line_number, acc}
    end
  end

  def run_alternatives(program, acc, line_number) do
    case Map.fetch(program, line_number) do
      {:ok, _instruction}   -> auxiliar(program, acc, line_number)
      :error                -> {line_number, acc}
    end
  end

  def auxiliar(program, acc, line_number) do
    alternative_program = change_instruction(program, line_number)

    if alternative_program == nil do
      run_instruction(program, acc, line_number)
    else
      choose_program([
        run_instruction(program, acc, line_number),
        run(alternative_program, acc, line_number)
      ])
    end
  end

  def choose_program(collection) do
    Enum.max_by(collection, &(elem(&1, 0)))
  end

  def change_instruction(program, line_number) do
    instruction = Map.fetch!(program, line_number)

    case instruction do
      {:nop, value}   -> Map.put(program, line_number, {:jmp, value})
      {:jmp, offset}  -> Map.put(program, line_number, {:nop, offset})
      _               -> nil
    end
  end
end
