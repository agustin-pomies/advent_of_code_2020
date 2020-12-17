defmodule TicketTranslation do
  def get_data do
    [field_rules_string, my_ticket_string, nearby_tickets_string | _] = IOModule.get_input("16", "\n\n")

    field_rules =
      field_rules_string
      |> String.split("\n", trim: true)
      |> Enum.map(&(String.split(&1, ": ")))
      |> Enum.map(fn [field, rules_string | _] -> {field, parse_rules(rules_string)} end)
      |> Enum.map(fn {field, rules} -> %{field => rules} end)
      |> Enum.reduce(%{}, fn field_rules, acc -> Map.merge(field_rules, acc) end)

    my_ticket =
      my_ticket_string
      |> String.split("\n", trim: true)
      |> List.last()
      |> String.split(",")
      |> Enum.map(&(Helper.to_integer(&1)))

    nearby_tickets = 
      nearby_tickets_string
      |> String.split("\n", trim: true)
      |> tl()
      |> Enum.map(&(String.split(&1, ",")))
      |> Enum.map(fn elem -> Enum.map(elem, &(Helper.to_integer(&1))) end)

    %{field_rules: field_rules, my_ticket: my_ticket, nearby_tickets: nearby_tickets}
  end

  def parse_rules(rules_string) do
    rules_string
    |> String.split(" or ")
    |> Enum.map(&(String.split(&1, "-")))
    |> Enum.map(fn [min, max | _] -> {Helper.to_integer(min), Helper.to_integer(max)} end)
  end

  def valid_ticket?([], _), do: {true, nil}
  def valid_ticket?([number | numbers], field_rules) do
    case match_field_rules?(number, Map.values(field_rules)) do
      nil     -> valid_ticket?(numbers, field_rules)
      number  -> {false, number}
    end
  end

  def match_field_rules?(number, []), do: number
  def match_field_rules?(number, [rule | rules]) do
    if match_rule?(number, rule), do: nil, else: match_field_rules?(number, rules)
  end

  def match_rule?(number, [{min_a, max_a}, {min_b, max_b} | _]) do
    Enum.member?(min_a..max_a, number) || Enum.member?(min_b..max_b, number)
  end

  def part_one do
    data = get_data()
    field_rules = Map.fetch!(data, :field_rules)
    
    Map.fetch!(data, :nearby_tickets)
    |> Enum.map(&(valid_ticket?(&1, field_rules)))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.filter(fn elem -> elem != nil end)
    |> Enum.reduce(0, fn elem, acc -> elem + acc end)
  end

  def part_two do
    0
  end
end
