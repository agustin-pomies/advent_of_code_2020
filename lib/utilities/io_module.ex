defmodule IOModule do
  def get_input(number, separator \\ "\n") do
    input_path = Path.join(["inputs", "examples", Integer.to_string(number) <> ".txt"])

    case File.read(input_path) do
      {:ok, file} -> String.split(file, separator, trim: true)
      {:error, reason} -> reason
    end
  end
end
