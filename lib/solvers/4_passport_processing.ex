defmodule PassportProcessing do
  def get_data do
    IOModule.get_input("4", "\n\n") |> parse_input()
  end

  def part_one do
    get_data() |> Enum.filter(&valid_passport_1?(&1)) |> length()
  end

  def part_two do
    get_data() |> Enum.filter(&valid_passport_2?(&1)) |> length()
  end

  def parse_input(strings) do
    strings
    |> Enum.map(&String.replace(&1, "\n", " "))
    |> Enum.map(&scan_with_regex(&1))
  end

  def scan_with_regex(passport_string) do
    regex = ~r"([[:graph:]]+):([[:graph:]]+)"

    case Regex.scan(regex, passport_string) do
      [head | tail] -> Enum.map([head | tail], &Enum.drop(&1, 1)) |> build_map()
      [] -> IO.puts(passport_string)
    end
  end

  def build_map(key_value_pairs) do
    Enum.reduce(key_value_pairs, %{}, fn [key, value], passport ->
      Map.put(passport, key, value)
    end)
  end

  def valid_passport_1?(passport) do
    Enum.all?(required_fields(), &Map.has_key?(passport, &1))
  end

  def valid_passport_2?(passport) do
    ecl_values = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    hcl_format = ~r"^#[[:xdigit:]]{6}$"
    pid_format = ~r"^[[:digit:]]{9}$"

    required_keys = Enum.all?(required_fields(), &Map.has_key?(passport, &1))

    if required_keys do
      validations = %{
        byr: Map.fetch(passport, "byr") |> elem(1) |> to_integer() |> check_range(1920, 2002),
        iyr: Map.fetch(passport, "iyr") |> elem(1) |> to_integer() |> check_range(2010, 2020),
        eyr: Map.fetch(passport, "eyr") |> elem(1) |> to_integer() |> check_range(2020, 2030),
        hgt: Map.fetch(passport, "hgt") |> elem(1) |> parse_height() |> check_height(),
        hcl: Map.fetch(passport, "hcl") |> elem(1) |> String.match?(hcl_format),
        pid: Map.fetch(passport, "pid") |> elem(1) |> String.match?(pid_format),
        ecl: Enum.member?(ecl_values, elem(Map.fetch(passport, "ecl"), 1))
      }

      validations
      |> Map.values()
      |> Enum.all?()
    else
      false
    end
  end

  def required_fields do
    ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
  end

  def check_range(number, min, max) do
    min <= number && number <= max
  end

  def parse_height(height_string) do
    regex = ~r"([[:digit:]]+)([[:alpha:]]+)"

    case Regex.scan(regex, height_string) do
      [head | tail] -> [head | tail] |> hd() |> tl()
      [] -> [:error, :error]
    end
  end

  def check_height([value, unit]) do
    case unit do
      "cm" -> to_integer(value) |> check_range(150, 193)
      "in" -> to_integer(value) |> check_range(59, 76)
      _ -> false
    end
  end

  def to_integer(my_string) do
    case Integer.parse(my_string) do
      {number, _} -> number
      :error -> "It didn't work"
    end
  end
end
