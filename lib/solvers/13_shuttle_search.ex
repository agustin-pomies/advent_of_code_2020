defmodule ShuttleSearch do
  def get_data do
    data = IOModule.get_input(13)
    estimated_departure_time = hd(data) |> Helper.to_integer()

    bus_frequencies =
      List.last(data)
      |> String.split(",")
      |> Enum.filter(fn elem -> elem != "x" end)
      |> Enum.map(&Helper.to_integer(&1))

    {estimated_departure_time, bus_frequencies}
  end

  def get_data_2 do
    data =
      IOModule.get_input(13)
      |> List.last()
      |> String.split(",")

    Enum.zip(data, 0..length(data))
    |> Enum.filter(fn {frequency, _index} -> frequency != "x" end)
    |> Enum.map(fn {frequency, index} -> {Helper.to_integer(frequency), index} end)
    |> Enum.map(fn {frequency, index} ->
      {frequency, if(index != 0, do: frequency - index, else: 0)}
    end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
  end

  def part_one do
    {estimated_departure_time, bus_frequencies} = get_data()

    bus_frequencies
    |> Enum.map(fn bus_frequency ->
      {bus_frequency, remaining_minutes(estimated_departure_time, bus_frequency)}
    end)
    |> Enum.min_by(fn x -> elem(x, 1) end)
    |> (fn {a, b} -> a * b end).()
  end

  def part_two do
    data = get_data_2()
    frequencies = Enum.map(data, &elem(&1, 0))
    combinations = for x <- frequencies, y <- frequencies, x != y, x < y, do: {x, y}

    if Enum.all?(combinations, fn {x, y} -> Chunky.Math.is_coprime?(x, y) end) do
      chinese_reminder_theorem(data) |> elem(1)
    else
      raise CommonFactors
    end
  end

  def remaining_minutes(goal, frequency) do
    float_division = goal / frequency
    nearest_integer_reached = Float.floor(float_division)

    frequency - trunc(Float.round((float_division - nearest_integer_reached) * frequency, 0))
  end

  def chinese_reminder_theorem(list) when length(list) == 1, do: hd(list)

  def chinese_reminder_theorem([{module_1, reminder_1} | [{module_2, reminder_2} | tail]] = list)
      when length(list) >= 2 do
    {b_1, b_2} = extended_gcd({module_1, module_2})
    new_module = module_1 * module_2
    new_reminder = rem(reminder_2 * b_1 * module_1 + reminder_1 * b_2 * module_2, new_module)
    new_reminder = if new_reminder < 0, do: new_reminder + new_module, else: new_reminder

    chinese_reminder_theorem([{new_module, new_reminder} | tail])
  end

  def extended_gcd({a, b}, {{old_s, s}, {old_t, t}} \\ {{1, 0}, {0, 1}}) do
    case b do
      0 ->
        {old_s, old_t}

      _ ->
        quotient = div(a, b)
        reminder = rem(a, b)
        extended_gcd({b, reminder}, {{s, old_s - quotient * s}, {t, old_t - quotient * t}})
    end
  end
end

defmodule CommonFactors do
  defexception message: "There are common factors in certain pair of numbers inside given set"
end
