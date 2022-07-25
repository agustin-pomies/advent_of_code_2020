defmodule AllergenAssessment do
  def get_data do
    IOModule.get_input(21, "\r\n")
    |> Enum.map(&parse_food(&1))
  end

  def parse_food(food_line) do
    regex = ~r/^(?<ingredients>^[[:alpha:][:blank:]]+) \(contains (?<allergens>[[:alpha:],[:blank:]]+)\)$/
    
    case Regex.named_captures(regex, food_line) do
      %{"ingredients" => ingredients, "allergens" => allergens} -> %{"ingredients" => String.split(ingredients, " ", trim: true), "allergens" => String.split(allergens, ", ", trim: true)}
      nil                                                       -> IO.puts(food_line)
    end
  end


  def part_one do
    get_data()
    |> determine_occurrences_and_possibilities()
    |> determine_ingredients_with_no_allergens()
    |> Map.values()
    |> Enum.sum()
  end

  def determine_occurrences_and_possibilities(ingredients_and_allergens) do
    Enum.reduce(
      ingredients_and_allergens,
      %{"occurrences" => %{}, "possibilities" => %{}},
      fn food, acc -> update_accumulator(food, acc) end
    )
  end

  def update_accumulator(food, occurrences_and_possibilities) do
    new_occurrences =
      occurrences_and_possibilities
      |> occurrences()
      |> update_occurrences(ingredients(food))

    new_possibilities =
      occurrences_and_possibilities
      |> possibilities()
      |> update_possibilities(allergens(food), ingredients(food))

    occurrences_and_possibilities
    |> Map.put("occurrences", new_occurrences)
    |> Map.put("possibilities", new_possibilities)
  end

  def update_occurrences(occurrences, ingredients) do
    Enum.reduce(ingredients, occurrences, fn ingredient, new_occurences -> Map.update(new_occurences, ingredient, 1, &(&1 + 1)) end)
  end

  def update_possibilities(possibilities, allergens, ingredients) do
    Enum.reduce(allergens, possibilities, fn allergen, new_possibilities -> update_allergen_possibilities(new_possibilities, allergen, ingredients) end)
  end

  def update_allergen_possibilities(new_possibilities, allergen, ingredients) do
    Map.update(new_possibilities, allergen, Enum.into(ingredients, MapSet.new), &(common_elements(&1, ingredients)))
  end

  def common_elements(current_possibilities, ingredients) do
    MapSet.intersection(current_possibilities, Enum.into(ingredients, MapSet.new))
  end

  def occurrences(occurrences_and_possibilities) do
    Map.fetch!(occurrences_and_possibilities, "occurrences")
  end

  def possibilities(occurrences_and_possibilities) do
    Map.fetch!(occurrences_and_possibilities, "possibilities")
  end

  def ingredients(food) do
    Map.fetch!(food, "ingredients")
  end

  def allergens(food) do
    Map.fetch!(food, "allergens")
  end

  def determine_ingredients_with_no_allergens(occurrences_and_possibilities) do
    ingredients_potentially_containing_allergens =
      occurrences_and_possibilities
      |> possibilities()
      |> Map.values()
      |> Enum.reduce(&(MapSet.union(&1, &2)))
      |> MapSet.to_list()

    occurrences_and_possibilities
    |> occurrences()
    |> Map.drop(ingredients_potentially_containing_allergens)
  end

  def part_two do
    get_data()
    |> determine_occurrences_and_possibilities()
    |> possibilities()
    |> determine_allergens_in_ingredients(%{})
    |> canonical_dangerous_ingredient_list()
  end

  def determine_allergens_in_ingredients(possibilities, deductions) when possibilities == %{} do
    deductions
  end

  def determine_allergens_in_ingredients(possibilities, deductions) do
    deduced_ingredients =
      possibilities
      |> Enum.filter(fn {k, v} -> MapSet.size(v) == 1 end)
      |> Enum.reduce(%{}, fn {allergen, ingredient}, acc -> Map.put(acc, allergen, hd(MapSet.to_list(ingredient))) end)

    new_deductions = Map.merge(deductions, deduced_ingredients)
    uncertain_possibilites = Map.drop(possibilities, Map.keys(deduced_ingredients))

    new_possibilities = Enum.reduce(
      deduced_ingredients,
      uncertain_possibilites,
      fn {_, ingredient}, acc -> remove_ingredient_from_options(acc, ingredient) end
    )

    determine_allergens_in_ingredients(new_possibilities, new_deductions)
  end

  def remove_ingredient_from_options(uncertain_possibilites, ingredient) do
    for {allergen, options} <- uncertain_possibilites, into: %{}, do: {allergen, MapSet.delete(options, ingredient)}
  end

  def canonical_dangerous_ingredient_list(allergens_in_ingredients) do
    allergens_in_ingredients
    |> Map.to_list()
    |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.join(",")
  end
end
