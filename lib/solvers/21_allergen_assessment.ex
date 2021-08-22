defmodule AllergenAssessment do
  def get_data do
    IOModule.get_input("21", "\r\n")
    |> Enum.map(&parse_food(&1))
  end

  def parse_food(food_line) do
    regex = ~r/^(?<ingredients>^[[:alpha:][:blank:]]+) \(contains (?<allergens>[[:alpha:],[:blank:]]+)\)$/
    
    case Regex.named_captures(regex, food_line) do
      %{"ingredients" => ingredients, "allergens" => allergens} -> %{"ingredients" => String.split(ingredients, " ", trim: true), "allergens" => String.split(allergens, ", ", trim: true)}
      nil                                                       -> IO.puts(food_line)
    end
  end

  def determine_occurrences_and_possibilites(ingredients_and_allergens) do
    Enum.reduce(
      ingredients_and_allergens,
      %{"occurrences" => %{}, "possibilites" => %{}},
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
      |> possibilites()
      |> update_possibilities(allergens(food), ingredients(food))

    occurrences_and_possibilities
    |> Map.put("occurrences", new_occurrences)
    |> Map.put("possibilites", new_possibilities)
  end

  def update_occurrences(occurrences, ingredients) do
    Enum.reduce(ingredients, occurrences, fn ingredient, new_occurences -> Map.update(new_occurences, ingredient, 1, &(&1 + 1)) end)
  end

  def update_possibilities(possibilites, allergens, ingredients) do
    Enum.reduce(allergens, possibilites, fn allergen, new_possibilites -> update_allergen_possibilites(new_possibilites, allergen, ingredients) end)
  end

  def update_allergen_possibilites(new_possibilites, allergen, ingredients) do
    Map.update(new_possibilites, allergen, Enum.into(ingredients, MapSet.new), &(common_elements(&1, ingredients)))
  end

  def common_elements(current_possibilities, ingredients) do
    MapSet.intersection(current_possibilities, Enum.into(ingredients, MapSet.new))
  end

  def occurrences(occurrences_and_possibilities) do
    Map.fetch!(occurrences_and_possibilities, "occurrences")
  end

  def possibilites(occurrences_and_possibilities) do
    Map.fetch!(occurrences_and_possibilities, "possibilites")
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
      |> possibilites()
      |> Map.values()
      |> Enum.reduce(&(MapSet.union(&1, &2)))
      |> MapSet.to_list()

    occurrences_and_possibilities
    |> occurrences()
    |> Map.drop(ingredients_potentially_containing_allergens)
  end

  def part_one do
    get_data()
    |> determine_occurrences_and_possibilites()
    |> determine_ingredients_with_no_allergens()
    |> Map.values()
    |> Enum.sum()
  end

  def part_two do
    0
  end
end
