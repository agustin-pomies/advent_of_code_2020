defmodule IOModule do
  def get_input(number) do
    case File.read("inputs/" <> number <> ".txt") do
      {:ok, file}      -> String.split(file, "\n", trim: true)
      {:error, reason} -> reason
    end
  end

  def show_output(output) do
    IO.puts("The answer is #{output}")
  end
end
