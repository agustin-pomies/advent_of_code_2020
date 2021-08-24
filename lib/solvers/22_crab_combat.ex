defmodule CrabCombat do
  def get_data do
    lines = IOModule.get_input("22", "\r\n")

    [deck_1, deck_2 | _] = 
      Enum.split(lines, div(length(lines), 2))
      |> Tuple.to_list()
      |> Enum.map(&(Enum.drop(&1, 1)))
      |> Enum.map(fn deck -> Enum.map(deck, &(Helper.to_integer(&1))) end)

    {deck_1, deck_2}
  end

  def part_one do
    __MODULE__.get_data()
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
    {:ok, file} = File.open("output.txt", [:append])

    score = 
      __MODULE__.get_data()
      |> recursive_combat_game({1, 1})
      |> winning_score()

    IO.puts(file, "")
    IO.puts(file, "Final Score: #{score}")

    score
  end

  def recursive_combat_game({deck_1, deck_2}, {game, round}) do
    cond do
      deck_1 == []                          -> deck_2
      deck_2 == []                          -> deck_1
      normal_round?({deck_1, deck_2})       -> print_round(game, round, {deck_1, deck_2}) |> recursive_combat_round_new_state(hd(deck_1) > hd(deck_2), {game, round}) |> recursive_combat_game({game, round + 1})
      true                                  -> print_round(game, round, {deck_1, deck_2}) |> starting_subgame(game + 1) |> recursive_combat_round_new_state(subgame({deck_1 |> tl() |> Enum.take(hd(deck_1)), deck_2 |> tl() |> Enum.take(hd(deck_2))}, [], {game + 1, 1}), {game, round}) |> recursive_combat_game({game, round + 1})
    end
  end

  def normal_round?({deck_1, deck_2}) do
    hd(deck_1) >= length(deck_1) or hd(deck_2) >= length(deck_2)
  end

  def recursive_combat_round_new_state({[card_1 | deck_1], [card_2 | deck_2]}, result, {game, round}) do
    if result do
      print_round_result(game, round, 1)

      {deck_1 ++ [card_1, card_2], deck_2}
    else
      print_round_result(game, round, 2)

      {deck_1, deck_2 ++ [card_2, card_1]}
    end
  end

  def subgame({subdeck_1, subdeck_2}, configurations, {game, round}) do
    cond do
      subdeck_1 == []                           -> ending_subgame(false, game, 2)
      subdeck_2 == []                           -> ending_subgame(true, game, 1)
      {subdeck_1, subdeck_2} in configurations  -> ending_subgame(true, game, 1)
      normal_round?({subdeck_1, subdeck_2})     -> print_round(game, round, {subdeck_1, subdeck_2}) |> recursive_combat_round_new_state(hd(subdeck_1) > hd(subdeck_2), {game, round}) |> subgame([{subdeck_1, subdeck_2} | configurations], {game, round + 1})
      true                                      -> print_round(game, round, {subdeck_1, subdeck_2}) |> starting_subgame(game + 1) |> recursive_combat_round_new_state(subgame({subdeck_1 |> tl() |> Enum.take(hd(subdeck_1)), subdeck_2 |> tl() |> Enum.take(hd(subdeck_2))}, [], {game + 1, 1}), {game, round}) |> subgame([{subdeck_1, subdeck_2} | configurations], {game, round + 1})
    end
  end

  # Debug Output
  def print_game_header(number) do
    {:ok, file} = File.open("output.txt", [:append])

    IO.puts(file, "=== Game #{number} ===")
  end

  def print_round(game, round, {deck_1, deck_2}) do
    {:ok, file} = File.open("output.txt", [:append])

    IO.puts(file, "")
    IO.puts(file, "-- Round #{round} (Game #{game}) --")
    IO.puts(file, "Player 1's deck: #{Enum.join(deck_1, ", ")}")
    IO.puts(file, "Player 2's deck: #{Enum.join(deck_2, ", ")}")
    IO.puts(file, "Player 1 plays: #{hd(deck_1)}")
    IO.puts(file, "Player 2 plays: #{hd(deck_2)}")

    {deck_1, deck_2}
  end

  def print_round_result(game, round, player) do
    {:ok, file} = File.open("output.txt", [:append])

    IO.puts(file, "Player #{player} wins round #{round} of game #{game}!")
  end

  def print_game_winner(game, player) do
    {:ok, file} = File.open("output.txt", [:append])

    IO.puts(file, "The winner of game #{game} is player #{player}!")
    IO.puts(file, "")
  end

  def starting_subgame(result, game) do
    print_playing_subgame()
    print_game_header(game)

    result
  end

  def print_playing_subgame() do
    {:ok, file} = File.open("output.txt", [:append])

    IO.puts(file, "Playing a sub-game to determine the winner...")
    IO.puts(file, "")
  end

  def print_returning_parent_game(number) do
    {:ok, file} = File.open("output.txt", [:append])

    IO.puts(file, "...anyway, back to game #{number}.")
  end

  def ending_subgame(result, game, player) do
    print_game_winner(game, player)
    print_returning_parent_game(game - 1)

    result
  end
end
