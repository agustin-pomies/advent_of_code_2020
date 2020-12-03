# defmodule PasswordChecker do
#   def import_password_and_policies_list(file_path) do
#     password_and_policies_list = 
#       case File.read(file_path) do
#         {:ok, file}      -> String.split(file, "\n", trim: true)
#         {:error, reason} -> IO.puts(reason)
#       end

#     password_and_policies_list
#     |> Enum.map(&(parse_input_line(&1)))
#     |> Enum.map(fn (map) -> [elem(map, 0), elem(map, 1)] end)
#     |> Enum.reduce(0, fn ([password, policy], acc) -> if check_password(password, policy), do: acc + 1, else: acc end)
#   end

#   defp convert_to_integer(my_string) do
#     result = Integer.parse(my_string)

#     case result do
#       {number, _} -> number
#       :error -> "It didn't work"
#     end
#   end

#   defp parse_input_line(input_line) do
#     regex = ~r"(\d+)-(\d+) (\w): (.+)"

#     case Regex.run(regex, input_line) do
#       [_ | tail] -> build_data(tail)
#       nil -> IO.puts(input_line)
#     end
#   end

#   defp build_data([minimum, maximum, character, password]) do
#     policy = {convert_to_integer(minimum), convert_to_integer(maximum), character}

#     {password, policy}
#   end

#   defp check_password(password, policy) do
#     minimum = elem(policy, 0)
#     maximum = elem(policy, 1)
#     character = elem(policy, 2)

#     password
#     |> String.graphemes()
#     |> Enum.reduce(0, fn char, acc ->
#         if (char == character) do
#           acc + 1
#         else
#           acc
#         end
#       end)
#     |> inside_range(minimum, maximum)
#   end

#   defp inside_range(number, minimum, maximum) do
#     Enum.member?(minimum..maximum, number)
#   end
# end

# defmodule PasswordChecker do
#   def import_password_and_policies_list(file_path) do
#     password_and_policies_list = 
#       case File.read(file_path) do
#         {:ok, file}      -> String.split(file, "\n", trim: true)
#         {:error, reason} -> IO.puts(reason)
#       end

#     password_and_policies_list
#     |> Enum.map(&(parse_input_line(&1)))
#     |> Enum.map(fn (map) -> [elem(map, 0), elem(map, 1)] end)
#     |> Enum.reduce(0, fn ([password, policy], acc) -> if check_password(password, policy), do: acc + 1, else: acc end)
#   end

#   defp convert_to_integer(my_string) do
#     result = Integer.parse(my_string)

#     case result do
#       {number, _} -> number
#       :error -> "It didn't work"
#     end
#   end

#   defp parse_input_line(input_line) do
#     regex = ~r"(\d+)-(\d+) (\w): (.+)"

#     case Regex.run(regex, input_line) do
#       [_ | tail] -> build_data(tail)
#       nil -> IO.puts(input_line)
#     end
#   end

#   defp build_data([first_index, second_index, character, password]) do
#     policy = {convert_to_integer(first_index), convert_to_integer(second_index), character}

#     {password, policy}
#   end

#   defp check_password(password, policy) do
#     first_index = elem(policy, 0)
#     second_index = elem(policy, 1)
#     character = elem(policy, 2)

#     password
#     |> String.graphemes()
#     |> Enum.reduce({false, 1}, fn char, {result, index} ->
#         cond do
#           index == first_index ->
#             {char == character, index + 1}
#           index == second_index ->
#             {xor(result, char == character), index + 1}
#           true ->
#             {result, index + 1}
#         end
#       end)
#     |> elem(0)
#   end

#   defp xor(bool1, bool2) do
#     (!bool1 && bool2) || (bool1 && !bool2)
#   end
# end
