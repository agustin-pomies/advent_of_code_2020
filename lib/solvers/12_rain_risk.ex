defmodule RainRisk do
  def get_data do
    IOModule.get_input("12") |> parse_instructions()
  end

  def part_one do
    get_data()
    |> travel({0, 0}, :east)
    |> manhattan_distance()
  end

  def part_two do
    get_data()
    |> travel_to_waypoint({0, 0}, {10, 1})
    |> manhattan_distance()
  end

  def parse_instructions(lines) do
    lines
    |> Enum.map(&String.graphemes(&1))
    |> Enum.map(fn [symbol | number] -> {Map.fetch!(actions(), String.to_atom(symbol)), Helper.to_integer(Enum.join(number))} end)
  end

  def vectors do
    %{north: {0, 1}, south: {0, -1}, east: {1, 0}, west: {-1, 0}, left: -1, forward: 0, right: 1}
  end

  def actions do
    %{"N": :north, "S": :south, "E": :east, "W": :west, "L": :left, "F": :forward, "R": :right}
  end

  def positions do
    [:north, :south, :east, :west]
  end

  def orientations do
    [:left, :right]
  end

  def travel([], coordinates, _current_facing), do: coordinates

  def travel([instruction | navigation_instructions], coordinates, current_facing) do
    {new_coordinates, new_facing} = execute(instruction, coordinates, current_facing)

    travel(navigation_instructions, new_coordinates, new_facing)
  end

  def is_position?(action) do
    Enum.member?(positions(), action)
  end

  def is_orientation?(action) do
    Enum.member?(orientations(), action)
  end

  def execute({action, number} = instruction, coordinates, current_facing) do
    cond do
      action == :forward      -> {execute_position({current_facing, number}, coordinates), current_facing}
      is_position?(action)    -> {execute_position(instruction, coordinates), current_facing}
      is_orientation?(action) -> {coordinates, execute_orientation(instruction, current_facing)}
    end
  end

  def execute_position({position, number}, {x, y}) do
    Map.fetch!(vectors(), position)
    |> scalar_product(number)
    |> pair_sum({x, y})
  end

  def execute_orientation({orientation, number}, current_facing) do
    number_of_turns = trunc(number / 90)

    Map.fetch!(vectors(), orientation)
    |> Kernel.*(number_of_turns)
    |> new_orientation_1(current_facing)
  end

  def new_orientation_1(turns, current_facing) do
    directions = %{east: 0, south: 1, west: 2, north: 3}
    new_orientation_index = Map.fetch!(directions, current_facing) |> Kernel.+(turns)
    new_orientation_index = if new_orientation_index < 0, do: new_orientation_index + 4, else: rem(new_orientation_index, 4)

    Enum.find(directions, fn {_orientation, index} -> index == new_orientation_index end) |> elem(0)
  end

  def travel_to_waypoint([], ship_coordinates, _waypoint_coordinates), do: ship_coordinates

  def travel_to_waypoint([instruction | navigation_instructions], ship_coordinates, waypoint_coordinates) do
    {new_ship_coordinates, new_waypoint_coordinates} = execute_part_two_instruction(instruction, ship_coordinates, waypoint_coordinates)

    travel_to_waypoint(navigation_instructions, new_ship_coordinates, new_waypoint_coordinates)
  end

  def execute_part_two_instruction({action, _number} = instruction, ship_coordinates, waypoint_coordinates) do
    cond do
      action == :forward      -> {execute_homothecy(instruction, ship_coordinates, waypoint_coordinates), waypoint_coordinates}
      is_position?(action)    -> {ship_coordinates, execute_translation(instruction, waypoint_coordinates)}
      is_orientation?(action) -> {ship_coordinates, execute_rotation(instruction, waypoint_coordinates)}
    end
  end

  def execute_homothecy({_action, number}, ship_coordinates, waypoint_coordinates) do
    scalar_product(waypoint_coordinates, number) |> pair_sum(ship_coordinates)
  end

  def execute_translation({position, number}, {w, v}) do
    Map.fetch!(vectors(), position)
    |> scalar_product(number)
    |> pair_sum({w, v})
  end

  def execute_rotation({action, number}, waypoint_coordinates) do
    Map.fetch!(vectors(), action)
    |> Kernel.*(number)
    |> new_orientation_2(waypoint_coordinates)
  end

  def new_orientation_2(turns, waypoint_coordinates) do
    abs_turns = abs(turns)
    clockwise_rotation_matrix = [{cos(abs_turns), - sin(abs_turns)}, {sin(abs_turns), cos(abs_turns)}]
    anticlockwise_rotation_matrix = [{cos(abs_turns), sin(abs_turns)}, {- sin(abs_turns), cos(abs_turns)}]
    rotation_matrix = if turns > 0, do: clockwise_rotation_matrix, else: anticlockwise_rotation_matrix    
    
    matrix_multiplication(waypoint_coordinates, rotation_matrix)
  end

  def matrix_multiplication({x, y}, [{a, b}, {c, d}]) do
    {(x * a) + (y * c), (x * b) + (y * d)}
  end

  def pair_substract({a, b}, {c, d}) do
    {a - c, b - d}
  end

  def pair_sum({a, b}, {c, d}) do
    {a + c, b + d}
  end

  def scalar_product({a, b}, {c, d}) do
    {a * c, b * d}
  end

  def scalar_product({a, b}, scalar) do
    {a * scalar, b * scalar}
  end

  def cos(number) do
    correspondence = %{0 => 1, 90 => 0, 180 => -1, 270 => 0, 360 => 1}

    Map.fetch!(correspondence, number)
  end

  def sin(number) do
    correspondence = %{0 => 0, 90 => 1, 180 => 0, 270 => -1, 360 => 0}

    Map.fetch!(correspondence, number)
  end

  def manhattan_distance({x, y}) do
    abs(x) + abs(y)
  end
end
