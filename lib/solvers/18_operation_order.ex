defmodule OperationOrder do
  def get_data do
    IOModule.get_input("18")
    |> Enum.map(&(String.replace(&1, ["(", ")"], fn char -> " " <> char <> " " end)))
    |> Enum.map(&(String.split(&1, " ", trim: true)))
  end

  def part_one do
    get_data()
    |> Enum.map(&(build_ast(&1, {[], []})))
    |> Enum.map(&(quote_expression(&1)))
    |> Enum.map(&(Code.eval_quoted(&1) |> elem(0)))
    |> Enum.reduce(&+/2)
  end

  def build_ast([], {[], nodes_queue}), do: hd(nodes_queue)
  def build_ast([], queues), do: build_ast([], build_subexpression(queues))
  def build_ast([char | subexpression] = expression, {operators_queue, nodes_queue} = queues) do
    cond do
      operator?(char) && length(operators_queue) > 0 && hd(operators_queue) != "("  -> build_ast(expression, build_subexpression(queues))
      operator?(char)                                                               -> build_ast(subexpression, {[char | operators_queue], nodes_queue})
      char == "("                                                                   -> build_ast(subexpression, {["(" | operators_queue], nodes_queue})
      char == ")" && hd(operators_queue) != "("                                     -> build_ast(expression, build_subexpression(queues))
      char == ")" && hd(operators_queue) == "("                                     -> build_ast(subexpression, {Enum.drop(operators_queue, 1), nodes_queue})
      true                                                                          -> build_ast(subexpression, {operators_queue, [char | nodes_queue]})
    end
  end

  def build_subexpression({[operator | operators_queue], [left, right | nodes_queue]}) do
    {operators_queue, [{operator, [right, left]} | nodes_queue]}
  end

  def operator?(string) do
    case string do
      "+" -> true
      "*" -> true
      _   -> false
    end
  end

  def quote_expression(expression) when is_bitstring(expression), do: Integer.parse(expression) |> elem(0)
  def quote_expression({operator, [left, right]}) do
    {String.to_atom(operator), [context: Elixir, import: Kernel], [quote_expression(left), quote_expression(right)]}
  end

  def part_two do
    0
  end
end
