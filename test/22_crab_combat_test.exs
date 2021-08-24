defmodule CrabCombatTest do
  use ExUnit.Case
  import Mock

  setup do
    simple_game = {[2, 1], [3, 4]}

    depth_1_game = {[2, 5, 3], [1, 6, 4]}
    infinite_loop_subgame = {[2, 43, 19], [3, 4, 29, 14]}

    example = {[9, 2, 6, 3, 1], [5, 8, 4, 7, 10]}

    {
      :ok,
      simple_game: simple_game,
      depth_1_game: depth_1_game,
      infinite_loop_subgame: infinite_loop_subgame,
      example: example
    }
  end

  test_with_mock "simple game for normal combat", %{simple_game: simple_game},
    CrabCombat, [:passthrough], [get_data: fn() -> simple_game end] do

    assert CrabCombat.part_one() == 27
  end

  test_with_mock "normal game for normal combat", %{depth_1_game: depth_1_game},
    CrabCombat, [:passthrough], [get_data: fn() -> depth_1_game end] do

    assert CrabCombat.part_one() == 80
  end

  test_with_mock "example game for normal combat", %{example: example},
    CrabCombat, [:passthrough], [get_data: fn() -> example end] do

    assert CrabCombat.part_one() == 306
  end

  test_with_mock "simple game for recursive combat", %{simple_game: simple_game},
    CrabCombat, [:passthrough], [get_data: fn() -> simple_game end] do

    assert CrabCombat.part_two() == 27
  end

  test_with_mock "depth-1 game for recursive combat", %{depth_1_game: depth_1_game},
    CrabCombat, [:passthrough], [get_data: fn() -> depth_1_game end] do

    assert CrabCombat.part_two() == 66
  end

  test_with_mock "example game for recursive combat", %{example: example},
    CrabCombat, [:passthrough], [get_data: fn() -> example end] do

    assert CrabCombat.part_two() == 291
  end
end
