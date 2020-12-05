defmodule PassportProcessing do
  def solve do
    get_input("input.txt")
    |> parse_input()
    |> Enum.filter(&(valid_passport?(&1)))
    |> length()
    |> show_output()
  end

  def get_input(file_name) do
    case File.read(file_name) do
      {:ok, file}      -> String.split(file, "\n\n", trim: true)
      {:error, reason} -> reason
    end
  end

  def show_output(output) do
    IO.puts("The answer is #{output}")
  end

  def parse_input(strings) do
    strings
    |> Enum.map(&(String.replace(&1, "\n", " ")))
    |> Enum.map(&(scan_with_regex(&1)))
  end

  def scan_with_regex(passport_string) do
    regex = ~r"([[:graph:]]+):([[:graph:]]+)"

    case Regex.scan(regex, passport_string) do
      [head | tail] -> Enum.map([head | tail], &(Enum.drop(&1, 1))) |> build_map()
      [] -> IO.puts(passport_string)
    end
  end

  def build_map(key_value_pairs) do
    Enum.reduce(key_value_pairs, %{}, fn [key, value], passport -> Map.put(passport, key, value) end)
  end

  def valid_passport?(passport) do
    Enum.all?(required_fields(), &(Map.has_key?(passport, &1)))
  end

  def required_fields do
    ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
  end
end
