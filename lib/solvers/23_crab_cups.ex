defmodule CrabCups do
  @moves 100
  @total_cups 9
  @cups_dropped 3

  def get_data do
    IOModule.get_input("23", "\r\n")
    |> hd()
    |> String.graphemes()
    |> Enum.map(&(Helper.to_integer(&1)))
  end

  def part_one do
    get_data()
    |> perform_moves(@moves)
    |> cups_final_order()
  end

  def perform_moves(cups_arrangement, 0), do: cups_arrangement
  def perform_moves([current_cup | cups_arrangement], moves_remaining) do
    cups_arrangement
    |> Enum.split(@cups_dropped)
    |> find_destination_cup(current_cup, current_cup - 1)
    |> new_cups_arrangement()
    |> perform_moves(moves_remaining - 1)
  end

  def find_destination_cup({picked_up_cups, remaining_cups}, current_cup, 0), do: find_destination_cup({picked_up_cups, remaining_cups}, current_cup, @total_cups)
  def find_destination_cup({picked_up_cups, remaining_cups}, current_cup, destination_cup) do
    destination_cup_index = Enum.find_index(remaining_cups, fn cup -> cup == destination_cup end)

    if destination_cup_index do
      {picked_up_cups, remaining_cups, current_cup, destination_cup_index}
    else
      find_destination_cup({picked_up_cups, remaining_cups}, current_cup, destination_cup - 1)
    end
  end

  def new_cups_arrangement({picked_up_cups, remaining_cups, current_cup, destination_cup_index}) do
    {before_with_destination_included, after_destination} = Enum.split(remaining_cups, destination_cup_index + 1)

    before_with_destination_included ++ picked_up_cups ++ after_destination ++ [current_cup]
  end

  def cups_final_order(cups_arrangement) do
    cups_arrangement
    |> Enum.split_while(fn x -> x != 1 end)
    |> Tuple.to_list()
    |> Enum.reverse()
    |> Enum.reduce(&(&2 ++ &1))
    |> Enum.map(&(Integer.to_string(&1)))
    |> tl()
  end

  def part_two do
    0
  end
end
