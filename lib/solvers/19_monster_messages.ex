defmodule MonsterMessages do
  def get_data do
    [rules, messages] =
      IOModule.get_input("19", "\n\n")
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

    valid_strings =
      data
      |> Map.fetch!(:rules)
      |> valid_strings_for_rule(0)

    data
    |> Map.fetch!(:messages)
    |> Enum.reduce(0, fn message, acc -> acc + if Enum.member?(valid_strings, message), do: 1, else: 0 end)
  end

  def valid_strings_for_rule(rules, rule_number) do
    rules
    |> Map.fetch!(rule_number)
    |> Enum.reduce([], fn alternative, strings -> strings ++ build_alternative(rules, alternative) end)
  end

  def build_alternative(rules, alternative) do
    Enum.reduce(alternative, [""], fn elem, acc -> concatenation(acc, build_strings(rules, elem)) end)
  end

  def build_strings(rules, symbol) do
    cond do
      is_integer(symbol)    -> valid_strings_for_rule(rules, symbol)
      is_bitstring(symbol)  -> [symbol]
    end
  end

  def concatenation(collection_1, collection_2) do
    for x <- collection_1, y <- collection_2, do: x <> y
  end

  def part_two do
    0
  end
end
