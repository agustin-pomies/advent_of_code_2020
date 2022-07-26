defmodule AdventOfCode2020 do
  def puzzles_names do
    Path.join(["lib", "solvers", "*.ex"])
    |> Path.wildcard()
    |> Enum.map(&Path.relative_to(&1, Path.join(["lib", "solvers"])))
    |> Enum.map(&parse_file_name(&1))
    |> Enum.reduce(fn elem, acc -> Map.merge(elem, acc) end)
  end

  def parse_file_name(file_name) do
    [day_number | terms] =
      file_name
      |> String.replace_suffix(".ex", "")
      |> String.split("_")

    puzzle_name =
      terms
      |> Enum.map(&Macro.camelize(&1))
      |> Enum.join(" ")

    %{Helper.to_integer(day_number) => puzzle_name}
  end

  def solve do
    IO.puts("---------------------------------")
    IO.puts("       ADVENT OF CODE 2020       ")
    IO.puts("---------------------------------")

    puzzles_names()
    |> Enum.each(&display_puzzle(&1))
  end

  def solve(day_number) do
    display_puzzle(day_number)
  end

  def display_puzzle({day_number, puzzle_name}) do
    module = get_module(day_number)

    display_puzzle(day_number, puzzle_name, module)
  end

  def display_puzzle(day_number) do
    puzzle_name = get_puzzle_name(day_number)
    module = get_module(day_number)

    display_puzzle(day_number, puzzle_name, module)
  end

  def display_puzzle(day_number, puzzle_name, module) do
    args = System.argv()

    IO.puts("Day #{day_number}: #{puzzle_name}")

    if Enum.empty?(args) || Enum.member?(args, "1") do
      IO.puts("Part One - #{module.part_one()}")
    end

    if Enum.empty?(args) || Enum.member?(args, "2") do
      IO.puts("Part Two - #{module.part_two()}")
    end

    IO.puts("---------------------------------")
  end

  def get_puzzle_name(day_number) do
    Map.fetch!(puzzles_names(), day_number)
  end

  def get_module(day_number) do
    puzzle_name = get_puzzle_name(day_number)
    module_name = String.split(puzzle_name, " ") |> Enum.join()
    module = String.to_existing_atom("Elixir." <> module_name)

    module
  end
end
