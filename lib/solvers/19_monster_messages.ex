defmodule MonsterMessages do
  def get_data do
    [rules, messages] =
      IOModule.get_input(19, "\n\n")
      |> Enum.map(&(String.split(&1, "\n", trim: true)))

    parsed_rules =
      rules
      |> Enum.map(&(parse_rule(&1)))
      |> Enum.map(fn [a, b] -> {a, b} end) 
      |> Map.new

    %{rules: parsed_rules, messages: messages}
  end

  def parse_rule(string) do
    string
    |> String.split(":", trim: true)
    |> (fn [rule_number, string] -> [String.to_integer(rule_number), parse_rule_usage(string)] end).()
  end

  def parse_rule_usage(string) do
    string
    |> String.split("|", trim: true)
    |> Enum.map(&(String.split(&1, " ", trim: true)))
    |> Enum.map(fn alternative -> Enum.map(alternative, &(parse_char(&1))) end)
  end

  def parse_char(char) do
    cond do
      number?(char) -> String.to_integer(char)
      true          -> String.replace(char, "\"", "")
    end
  end

  def number?(char) do
    case Integer.parse(char) do
      {_number, _}  -> true
      :error        -> false
    end
  end

  def part_one do
    data = get_data()
    rules = Map.fetch!(data, :rules)
    messages = Map.fetch!(data, :messages)

    Enum.reduce(messages, 0, fn message, acc -> acc + if string_meets_rule?(message, rules, [0]), do: 1, else: 0 end)
  end

  def part_two do
    data = get_data() |> rules_adjustment()
    rules = Map.fetch!(data, :rules)
    messages = Map.fetch!(data, :messages)

    Enum.reduce(messages, 0, fn message, acc -> acc + if string_meets_rule?(message, rules, [0]), do: 1, else: 0 end)
  end

  def rules_adjustment(data) do
    new_rules =
      data
      |> Map.fetch!(:rules)
      |> Map.replace!(8, [[42], [42, 8]])
      |> Map.replace!(11, [[42, 31], [42, 11, 31]])

    Map.replace!(data, :rules, new_rules)
  end

  ## METHOD 3 (string deconstruction & subsequent elimination)
  # Matching string against rules and removing characters
  def string_meets_rule?("", _global_rules, []), do: true
  def string_meets_rule?("", _global_rules, rules) when length(rules) != 0, do: false
  def string_meets_rule?(string, _global_rules, []) when string != "", do: false
  def string_meets_rule?(string, global_rules, [rule | remaining_rules] = rules) do
    [character | remaining_string] = String.graphemes(string)
    remaining_string = Enum.join(remaining_string, "")

    case rule do
      rule when is_integer(rule)    -> split_parsing(string, global_rules, rule, remaining_rules)
      rule when is_bitstring(rule)  -> character == rule && string_meets_rule?(remaining_string, global_rules, remaining_rules)
    end
  end

  def split_parsing(string, global_rules, rule_number, current_rules) do
    global_rules
    |> Map.fetch!(rule_number)
    |> Enum.map(fn alternative -> alternative ++ current_rules end)
    |> Enum.any?(fn possible_rules -> string_meets_rule?(string, global_rules, possible_rules) end)
  end

  ## METHOD 2 (string deconstruction & substring matching)
  # Matching string against rules using try & error progressively

  # defmemo string_meets_rule?(string, rules, rule_number) do
  #   rules
  #   |> Map.fetch!(rule_number)
  #   |> Enum.any?(fn alternative -> string_meets_alternative?(string, rules, alternative) end)
  # end

  # defmemo string_meets_alternative?(string, rules, alternative) when length(alternative) == 1 do
  #   symbol = hd(alternative)

  #   cond do
  #     is_integer(symbol)  -> string_meets_rule?(string, rules, symbol)
  #     string == symbol    -> true
  #     true                -> false
  #   end
  # end

  # defmemo string_meets_alternative?(string, rules, alternative) when length(alternative) == 2 do
  #   length = String.length(string)
  #   possible_splits = 1..length-1

  #   Enum.any?(
  #     possible_splits,
  #     fn split ->
  #       String.split_at(string, split)
  #       |> Tuple.to_list()
  #       |> Enum.zip(alternative)
  #       |> Enum.all?(fn {string, rule} -> string_meets_rule?(string, rules, rule) end)
  #     end
  #   )
  # end

  # defmemo string_meets_alternative?(string, rules, alternative) when length(alternative) == 3 do
  #   length = String.length(string)
  #   possible_splits = tuples_2d(length)

  #   Enum.any?(
  #     possible_splits,
  #     fn [split_1, split_2] ->
  #       {string_1, res} = String.split_at(string, split_1)
  #       {string_2, string_3} = String.split_at(res, split_2 - split_1)

  #       [string_1, string_2, string_3]
  #       |> Enum.zip(alternative)
  #       |> Enum.all?(fn {string, rule} -> string_meets_rule?(string, rules, rule) end)
  #     end
  #   )
  # end

  # def tuples_2d(number) do
  #   for x <- 1..number-1, y <- 1..number-1, x < y, do: [x, y]
  # end

  ## METHOD 1 (construction of all valid possibilites)
  # Building strings belonging to defined language

  # def valid_strings_for_rule(rules, rule_number) do
  #   rules
  #   |> Map.fetch!(rule_number)
  #   |> Enum.reduce([], fn alternative, strings -> strings ++ build_alternative(rules, alternative) end)
  # end

  # def build_alternative(rules, alternative) do
  #   Enum.reduce(alternative, [""], fn elem, acc -> concatenation(acc, build_strings(rules, elem)) end)
  # end

  # def build_strings(rules, symbol) do
  #   cond do
  #     is_integer(symbol)    -> valid_strings_for_rule(rules, symbol)
  #     is_bitstring(symbol)  -> [symbol]
  #   end
  # end

  # def concatenation(collection_1, collection_2) do
  #   for x <- collection_1, y <- collection_2, do: x <> y
  # end
end
