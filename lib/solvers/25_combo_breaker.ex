defmodule ComboBreaker do
  @modulus 2020_12_27
  @initial_subject_number 7

  def get_data do
    IOModule.get_input(25, "\r\n")
    |> Enum.map(&String.to_integer/1)
  end

  def part_one do
    public_keys = get_data()

    secret_loops =
      Enum.map(public_keys, fn public_key -> loop({1, public_key}, @initial_subject_number, 0) end)

    [{_, loop_size}, {chosen_candidate, _}] =
      [public_keys, secret_loops]
      |> Enum.zip()
      |> Enum.sort(fn a, b -> elem(a, 1) <= elem(b, 1) end)

    perform_steps(1, chosen_candidate, loop_size)
  end

  def perform_steps(current_number, _, 0), do: current_number

  def perform_steps(current_number, subject_number, loop_size) do
    rem(current_number * subject_number, @modulus)
    |> perform_steps(subject_number, loop_size - 1)
  end

  def loop({current_number, objective}, _, loop_size) when current_number == objective,
    do: loop_size

  def loop({current_number, objective}, subject_number, loop_size) do
    new_number = rem(current_number * subject_number, @modulus)

    loop({new_number, objective}, subject_number, loop_size + 1)
  end

  def part_two do
    nil
  end
end
