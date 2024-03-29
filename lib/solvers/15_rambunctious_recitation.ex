defmodule RambunctiousRecitation do
  def get_data do
    IOModule.get_input(15)
    |> hd()
    |> String.split(",")
    |> Enum.map(&Helper.to_integer(&1))
  end

  def part_one do
    numbers = get_data()

    last_number_spoken = List.last(numbers)
    last_step = length(numbers)

    last_appeareances =
      Enum.zip(numbers, 1..length(numbers))
      |> Enum.reduce(%{}, fn {number, index}, acc -> Map.merge(acc, %{number => {nil, index}}) end)

    continue_sequence(last_number_spoken, last_step, last_appeareances, 2020)
  end

  def continue_sequence(last_number_spoken, last_step, last_appeareances, stop) do
    if last_step == stop do
      last_number_spoken
    else
      if !first_time_spoken?(last_appeareances, last_number_spoken) do
        {penultimate, last} = Map.fetch!(last_appeareances, last_number_spoken)
        number_to_be_spoken = last - penultimate

        next_step = last_step + 1

        new_appeareances =
          Map.put(
            last_appeareances,
            number_to_be_spoken,
            {previous_appeareance(last_appeareances, number_to_be_spoken), next_step}
          )

        continue_sequence(number_to_be_spoken, next_step, new_appeareances, stop)
      else
        number_to_be_spoken = 0

        next_step = last_step + 1

        new_appeareances =
          Map.put(
            last_appeareances,
            number_to_be_spoken,
            {previous_appeareance(last_appeareances, number_to_be_spoken), next_step}
          )

        continue_sequence(number_to_be_spoken, next_step, new_appeareances, stop)
      end
    end
  end

  def first_time_spoken?(last_appeareances, last_number_spoken) do
    Map.has_key?(last_appeareances, last_number_spoken) &&
      elem(Map.fetch!(last_appeareances, last_number_spoken), 0) == nil
  end

  def previous_appeareance(last_appeareances, last_number_spoken) do
    if Map.has_key?(last_appeareances, last_number_spoken) do
      Map.fetch!(last_appeareances, last_number_spoken) |> elem(1)
    else
      nil
    end
  end

  def part_two do
    numbers = get_data()

    last_number_spoken = List.last(numbers)
    last_step = length(numbers)

    last_appeareances =
      Enum.zip(numbers, 1..length(numbers))
      |> Enum.reduce(%{}, fn {number, index}, acc -> Map.merge(acc, %{number => {nil, index}}) end)

    continue_sequence(last_number_spoken, last_step, last_appeareances, 30_000_000)
  end
end
