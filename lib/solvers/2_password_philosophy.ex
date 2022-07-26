defmodule PasswordPhilosophy do
  @no_day 2

  @password_policy_regex ~r"(\d+)-(\d+) (\w): (.+)"

  defp order_attributes([lower_bound, upper_bound, char, password]) do
    {password, {String.to_integer(lower_bound), String.to_integer(upper_bound), char}}
  end

  defp parse_password_with_corporate_policy(input_line) do
    Regex.run(@password_policy_regex, input_line)
    |> tl()
    |> order_attributes()
  end

  def get_data do
    IOModule.get_input(@no_day)
    |> Enum.map(&parse_password_with_corporate_policy(&1))
  end

  defp meets_old_job_policy?({password, {min, max, given_letter} = _policy}) do
    count = String.graphemes(password) |> Enum.count(&(&1 == given_letter))

    Enum.member?(min..max, count)
  end

  def part_one do
    get_data() |> Enum.count(&meets_old_job_policy?(&1))
  end

  defp meets_official_toboggan_corporate_policy?(
         {password, {fst_pos, snd_pos, given_letter} = _policy}
       ) do
    [String.at(password, fst_pos - 1), String.at(password, snd_pos - 1)]
    |> Enum.count(&(&1 == given_letter)) == 1
  end

  def part_two do
    get_data() |> Enum.count(&meets_official_toboggan_corporate_policy?(&1))
  end
end
