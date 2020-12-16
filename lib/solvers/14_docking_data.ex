defmodule DockingData do
  def get_data do
    IOModule.get_input("14")
    |> Enum.map(&(parse_instruction(&1)))
  end

  def parse_instruction(line) do
    line_information = line |> String.split(" = ") |> List.to_tuple()
    
    if elem(line_information, 0) == "mask" do
      {:mask, elem(line_information, 1) |> parse_mask()}
    else
      {
        :memory,
        elem(line_information, 0) |> parse_memory_address(),
        elem(line_information, 1) |> binary_number()
      }
    end
  end

  def parse_mask(string_mask) do
    mask_list = string_mask |> String.graphemes()
    
    Enum.zip(0..length(mask_list), mask_list)
    |> Enum.filter(fn {_key, char} -> char != "X" end)
    |> Map.new()
  end

  def parse_memory_address(string_memory_allocation) do
    memory_allocation_regex = ~r/mem\[([[:digit:]]+)\]/

    Regex.run(memory_allocation_regex, string_memory_allocation)
    |> List.last()
    |> Integer.parse()
    |> elem(0)
  end

  def binary_number(string_decimal_number) do
    string_decimal_number
    |> Integer.parse()
    |> elem(0)
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
  end

  def part_one do
    get_data()
    |> run_program("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", %{})
    |> Map.values()
    |> Enum.reduce(fn elem, acc -> elem + acc end)
  end

  def run_program([], _, memory), do: memory
  def run_program([instruction | initialization_instructions], mask, memory) do
    case elem(instruction, 0) do
      :mask     -> run_program(initialization_instructions, elem(instruction, 1), memory)
      :memory   -> run_program(initialization_instructions, mask, execute_memory_allocation(instruction, mask, memory))
    end
  end

  def execute_memory_allocation({_, memory_address, value}, mask, memory) do
    masked_value = mask_value(mask, value) 

    Map.put(memory, memory_address, masked_value)
  end

  def mask_value(mask, value) do
    value_list = String.graphemes(value)
    
    Enum.reduce(mask, value_list, fn {index, char}, acc -> List.replace_at(acc, index, char) end)
    |> Enum.join("")
    |> Integer.parse(2)
    |> elem(0)
  end

  def part_two do
    0
  end
end
