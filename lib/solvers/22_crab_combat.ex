defmodule CrabCombat do
  def get_data do
    lines = IOModule.get_input("22", "\r\n")

    [deck_1, deck_2 | rem] = 
      Enum.split(lines, div(length(lines), 2))
      |> Tuple.to_list()
      |> Enum.map(&(Enum.drop(&1, 1)))
      |> Enum.map(fn deck -> Enum.map(deck, &(Helper.to_integer(&1))) end)

    {deck_1, deck_2}
  end

  def part_one do
    get_data()
    |> advance_round()
    |> winning_score()
  end

  def advance_round({deck_1, deck_2}) do
    cond do
      deck_1 == []  -> deck_2
      deck_2 == []  -> deck_1
      true          -> round_result({deck_1, deck_2}) |> advance_round()
    end
  end

  def round_result({[card_1 | deck_1], [card_2 | deck_2]}) do
    if card_1 > card_2 do
      {deck_1 ++ [card_1, card_2], deck_2}
    else
      {deck_1, deck_2 ++ [card_2, card_1]}
    end
  end

  def winning_score(winning_deck) do
    multipliers = Enum.to_list(length(winning_deck)..1)

    Enum.zip_reduce(winning_deck, multipliers, 0, fn x, y, acc -> (x * y) + acc end)
  end

  def part_two do
    0
  end
end
