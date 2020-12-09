defmodule Helper do
  def to_integer(my_string) do
    result = Integer.parse(my_string)

    case result do
      {number, _} -> number
      :error -> IO.puts(my_string)
    end
  end

  def xor(bool1, bool2) do
    (!bool1 && bool2) || (bool1 && !bool2)
  end
end
