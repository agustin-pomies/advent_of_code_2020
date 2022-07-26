defmodule OperationOrder do
  def get_data do
    IOModule.get_input(18)
    |> Enum.map(&String.replace(&1, ["(", ")"], fn char -> " " <> char <> " " end))
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  def part_one do
    get_data()
    |> Enum.map(&build_ast(&1, {[], []}, operator_priorities_1()))
    |> Enum.map(&quote_expression(&1))
    |> Enum.map(&(Code.eval_quoted(&1) |> elem(0)))
    |> Enum.reduce(&+/2)
  end

  def operator_priorities_1 do
    %{"+" => 0, "*" => 0}
  end

  def part_two do
    get_data()
    |> Enum.map(&build_ast(&1, {[], []}, operator_priorities_2()))
    |> Enum.map(&quote_expression(&1))
    |> Enum.map(&(Code.eval_quoted(&1) |> elem(0)))
    |> Enum.reduce(&+/2)
  end

  def operator_priorities_2 do
    %{"+" => 1, "*" => 0}
  end

  def build_ast([], {[], nodes_queue}, _), do: hd(nodes_queue)

  def build_ast([], queues, priorities),
    do: build_ast([], build_subexpression(queues), priorities)

  def build_ast(
        [char | subexpression] = expression,
        {operators_queue, nodes_queue} = queues,
        priorities
      ) do
    cond do
      operator?(char) && pending_operations?(operators_queue) &&
          lower_precedence?(char, operators_queue, priorities) ->
        build_ast(expression, build_subexpression(queues), priorities)

      operator?(char) ->
        build_ast(subexpression, {[char | operators_queue], nodes_queue}, priorities)

      char == "(" ->
        build_ast(subexpression, {["(" | operators_queue], nodes_queue}, priorities)

      char == ")" && hd(operators_queue) != "(" ->
        build_ast(expression, build_subexpression(queues), priorities)

      char == ")" && hd(operators_queue) == "(" ->
        build_ast(subexpression, {Enum.drop(operators_queue, 1), nodes_queue}, priorities)

      true ->
        build_ast(subexpression, {operators_queue, [char | nodes_queue]}, priorities)
    end
  end

  def build_subexpression({[operator | operators_queue], [left, right | nodes_queue]}) do
    {operators_queue, [{operator, [right, left]} | nodes_queue]}
  end

  def operator?(string) do
    case string do
      "+" -> true
      "*" -> true
      _ -> false
    end
  end

  def pending_operations?(operators_queue) do
    length(operators_queue) > 0 && hd(operators_queue) != "("
  end

  def lower_precedence?(char, operators_queue, priorities) do
    current_operator_priority = Map.fetch!(priorities, char)
    last_stacked_operator_priority = Map.fetch!(priorities, hd(operators_queue))

    last_stacked_operator_priority >= current_operator_priority
  end

  def quote_expression(expression) when is_bitstring(expression),
    do: Integer.parse(expression) |> elem(0)

  def quote_expression({operator, [left, right]}) do
    {String.to_atom(operator), [context: Elixir, import: Kernel],
     [quote_expression(left), quote_expression(right)]}
  end
end
