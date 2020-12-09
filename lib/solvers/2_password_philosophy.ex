defmodule PasswordPhilosophy do
  def get_data do
    IOModule.get_input("2")
  end

  def part_one do
    get_data()
    |> Enum.map(&parse_input_line_1(&1))
    |> Enum.map(fn map -> [elem(map, 0), elem(map, 1)] end)
    |> Enum.reduce(0, fn [password, policy], acc ->
      if check_password_1(password, policy), do: acc + 1, else: acc
    end)
  end

  def part_two do
    get_data()
    |> Enum.map(&parse_input_line_2(&1))
    |> Enum.map(fn map -> [elem(map, 0), elem(map, 1)] end)
    |> Enum.reduce(0, fn [password, policy], acc ->
      if check_password_2(password, policy), do: acc + 1, else: acc
    end)
  end

  defp parse_input_line_1(input_line) do
    regex = ~r"(\d+)-(\d+) (\w): (.+)"

    case Regex.run(regex, input_line) do
      [_ | tail] -> build_data_1(tail)
      nil -> IO.puts(input_line)
    end
  end

  defp parse_input_line_2(input_line) do
    regex = ~r"(\d+)-(\d+) (\w): (.+)"

    case Regex.run(regex, input_line) do
      [_ | tail] -> build_data_2(tail)
      nil -> IO.puts(input_line)
    end
  end

  defp build_data_1([minimum, maximum, character, password]) do
    policy = {Helper.to_integer(minimum), Helper.to_integer(maximum), character}

    {password, policy}
  end

  defp check_password_1(password, policy) do
    minimum = elem(policy, 0)
    maximum = elem(policy, 1)
    character = elem(policy, 2)

    password
    |> String.graphemes()
    |> Enum.reduce(0, fn char, acc ->
      if char == character do
        acc + 1
      else
        acc
      end
    end)
    |> inside_range(minimum, maximum)
  end

  defp inside_range(number, minimum, maximum) do
    Enum.member?(minimum..maximum, number)
  end

  defp build_data_2([first_index, second_index, character, password]) do
    policy = {Helper.to_integer(first_index), Helper.to_integer(second_index), character}

    {password, policy}
  end

  defp check_password_2(password, policy) do
    first_index = elem(policy, 0)
    second_index = elem(policy, 1)
    character = elem(policy, 2)

    password
    |> String.graphemes()
    |> Enum.reduce({false, 1}, fn char, {result, index} ->
        cond do
          index == first_index ->
            {char == character, index + 1}
          index == second_index ->
            {Helper.xor(result, char == character), index + 1}
          true ->
            {result, index + 1}
        end
      end)
    |> elem(0)
  end
end
