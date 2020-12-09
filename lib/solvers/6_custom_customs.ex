defmodule CustomCustoms do
  def get_data do
    IOModule.get_input("6", "\n\n") |> parse_input()
  end

  def part_one do
    get_data()
    |> Enum.map(&yes_answered_questions_1(&1))
    |> Enum.reduce(0, fn group_yes_answered_questions, acc ->
      group_yes_answered_questions + acc
    end)
  end

  def part_two do
    get_data()
    |> Enum.map(&yes_answered_questions_2(&1))
    |> Enum.reduce(0, fn group_yes_answered_questions, acc ->
      group_yes_answered_questions + acc
    end)
  end

  def parse_input(answers) do
    answers
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn group_answers -> Enum.map(group_answers, &String.graphemes(&1)) end)
    |> Enum.map(fn group_answers -> Enum.map(group_answers, &MapSet.new(&1)) end)
  end

  def yes_answered_questions_1(group_answers) do
    group_answers
    |> Enum.reduce(fn individual_answers, yes_answered_questions ->
      MapSet.union(individual_answers, yes_answered_questions)
    end)
    |> MapSet.to_list()
    |> length()
  end

  def yes_answered_questions_2(group_answers) do
    group_answers
    |> Enum.reduce(fn individual_answers, yes_answered_questions ->
      MapSet.intersection(individual_answers, yes_answered_questions)
    end)
    |> MapSet.to_list()
    |> length()
  end
end
