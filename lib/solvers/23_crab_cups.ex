defmodule CrabCups do
  @cups_picked 3

  @moves_1 100
  @total_cups_1 9

  @moves_2 10_000_000
  @total_cups_2 1_000_000

  def get_data do
    IOModule.get_input(23, "\r\n")
    |> hd()
    |> String.graphemes()
    |> Enum.map(&Helper.to_integer(&1))
  end

  def part_one do
    get_data()
    |> perform_moves(@moves_1, @total_cups_1)
    |> cups_final_order()
    |> Enum.map(&Integer.to_string(&1))
  end

  def perform_moves(cups_arrangement, 0, _), do: cups_arrangement

  def perform_moves([current_cup | cups_arrangement], moves_remaining, total_cups) do
    cups_arrangement
    |> Enum.split(@cups_picked)
    |> find_destination_cup(current_cup, current_cup - 1, total_cups)
    |> new_cups_arrangement()
    |> perform_moves(moves_remaining - 1, total_cups)
  end

  def find_destination_cup({picked_up_cups, remaining_cups}, current_cup, 0, total_cups),
    do:
      find_destination_cup({picked_up_cups, remaining_cups}, current_cup, total_cups, total_cups)

  def find_destination_cup(
        {picked_up_cups, remaining_cups},
        current_cup,
        destination_cup,
        total_cups
      ) do
    destination_cup_index = Enum.find_index(remaining_cups, fn cup -> cup == destination_cup end)

    if destination_cup_index do
      {picked_up_cups, remaining_cups, current_cup, destination_cup_index}
    else
      find_destination_cup(
        {picked_up_cups, remaining_cups},
        current_cup,
        destination_cup - 1,
        total_cups
      )
    end
  end

  def new_cups_arrangement({picked_up_cups, remaining_cups, current_cup, destination_cup_index}) do
    {before_with_destination_included, after_destination} =
      Enum.split(remaining_cups, destination_cup_index + 1)

    before_with_destination_included ++ picked_up_cups ++ after_destination ++ [current_cup]
  end

  def cups_final_order(cups_arrangement) do
    cups_arrangement
    |> Enum.split_while(fn x -> x != 1 end)
    |> Tuple.to_list()
    |> Enum.reverse()
    |> Enum.reduce(&(&2 ++ &1))
    |> tl()
  end

  def part_two do
    get_data()
    |> (fn x -> x ++ Enum.to_list((@total_cups_1 + 1)..@total_cups_2) end).()
    |> (fn x -> {build_circular_list(x, %{}, hd(x)), hd(x)} end).()
    |> perform_moves_2_0(@moves_2, @total_cups_2)
    |> cups_final_order_2_0()
    |> Enum.product()
  end

  def build_circular_list([elem], acc, original_head), do: Map.put(acc, elem, original_head)

  def build_circular_list([element_1, element_2 | tail], acc, original_head) do
    build_circular_list([element_2 | tail], Map.put(acc, element_1, element_2), original_head)
  end

  def perform_moves_2_0({circular_map, _}, 0, _), do: circular_map

  def perform_moves_2_0({circular_map, current_cup}, moves, total_cups) do
    next_cups = next_cups(circular_map, current_cup, @cups_picked, [])
    destination_cup = find_destination_cup_2_0(current_cup - 1, next_cups, total_cups)

    updates = [
      {current_cup, Map.get(circular_map, List.last(next_cups))},
      {destination_cup, hd(next_cups)},
      {List.last(next_cups), Map.get(circular_map, destination_cup)}
    ]

    new_circular_map = new_cups_arrangement_2_0(circular_map, updates)
    new_current_cup = Map.get(new_circular_map, current_cup)

    perform_moves_2_0({new_circular_map, new_current_cup}, moves - 1, total_cups)
  end

  def next_cups(_, _, 0, next_cups), do: next_cups

  def next_cups(circular_map, current_cup, cups_to_pick, next_cups) do
    next_cup = Map.get(circular_map, current_cup)

    next_cups(circular_map, next_cup, cups_to_pick - 1, next_cups ++ [next_cup])
  end

  def find_destination_cup_2_0(possible_destination, next_cups, total_cups) do
    cond do
      possible_destination < 1 ->
        find_destination_cup_2_0(total_cups, next_cups, total_cups)

      possible_destination in next_cups ->
        find_destination_cup_2_0(possible_destination - 1, next_cups, total_cups)

      true ->
        possible_destination
    end
  end

  def new_cups_arrangement_2_0(circular_map, updates) do
    Enum.reduce(updates, circular_map, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  def cups_final_order_2_0(cups_arrangement) do
    first_elem = Map.get(cups_arrangement, 1)
    second_elem = Map.get(cups_arrangement, first_elem)

    [first_elem, second_elem]
  end
end
