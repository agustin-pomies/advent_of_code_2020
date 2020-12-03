defmodule Helper do
  def convert_to_integer(my_string) do
    result = Integer.parse(my_string)

    case result do
      {number, _} -> number
      :error -> IO.puts(my_string)
    end
  end
end
