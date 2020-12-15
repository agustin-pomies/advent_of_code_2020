defmodule ShuttleSearch do
  def get_data do
    data = IOModule.get_input("13")
    estimated_departure_time = hd(data) |> Helper.to_integer()
    bus_frequencies =
      List.last(data)
      |> String.split(",")
      |> Enum.filter(fn elem -> elem != "x" end)
      |> Enum.map(&(Helper.to_integer(&1)))

    {estimated_departure_time, bus_frequencies}
  end

  def part_one do
    {estimated_departure_time, bus_frequencies} = get_data()

    bus_frequencies
    |> Enum.map(fn bus_frequency -> {bus_frequency, remaining_minutes(estimated_departure_time, bus_frequency)} end)
    |> Enum.min_by(fn x -> elem(x, 1) end)
    |> (fn {a, b} -> a * b end).()
  end

  def part_two do
    get_data()

    0
  end

  def remaining_minutes(goal, frequency) do
    float_division = goal / frequency
    nearest_integer_reached = Float.floor(float_division)

    frequency - trunc(Float.round((float_division - nearest_integer_reached) * frequency, 0))
  end
end
