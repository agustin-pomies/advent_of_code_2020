defmodule AdventOfCode2020 do
  def puzzles_names do
    %{
      1 => "Report Repair",
      2 => "Password Philosophy",
      3 => "Toboggan Trajectory",
      4 => "Passport Processing",
      5 => "Binary Boarding",
      6 => "Custom Customs"
    }
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
    IO.puts("Day #{day_number}: #{puzzle_name}")
    IO.puts("Part One - #{module.part_one()}")
    IO.puts("Part Two - #{module.part_two()}")
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
