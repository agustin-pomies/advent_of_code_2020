defmodule CustomCustoms do
  def solve do
    get_input("input.txt")
    |> parse_input()
    |> Enum.map(&(yes_answered_questions(&1)))
    |> Enum.reduce(0, fn group_yes_answered_questions, acc -> group_yes_answered_questions + acc end)
    |> show_output()
  end

  def get_input(file_name) do
    case File.read(file_name) do
      {:ok, file}      -> String.split(file, "\n\n", trim: true)
      {:error, reason} -> reason
    end
  end

  def parse_input(answers) do
    answers
    |> Enum.map(&(String.split(&1, "\n")))
    |> Enum.map(fn group_answers -> Enum.map(group_answers, &(String.graphemes(&1))) end)
    |> Enum.map(fn group_answers -> Enum.map(group_answers, &(MapSet.new(&1))) end)
  end

  def show_output(output) do
    IO.puts("The answer is #{output}")
  end

  def yes_answered_questions(group_answers) do
    group_answers
    |> Enum.reduce(fn individual_answers, yes_answered_questions -> MapSet.union(individual_answers, yes_answered_questions) end)
    |> MapSet.to_list()
    |> length()
  end
end
