defmodule ReportRepair do
  def fix_report(file_path) do
    expenses = import_expense_report(file_path)
    possible_pairs = cartesian_product(expenses, expenses)
    result = check_sum(possible_pairs)

    case result do
      {:ok , {x, y}} -> {{x, y}, x * y}
      {:error, reason} -> IO.puts(reason)
    end
  end
  defp import_expense_report(file_path) do
    report_data = 
      case File.read(file_path) do
        {:ok, file}      -> String.split(file, "\n")
        {:error, reason} -> IO.puts(reason)
      end

    expenses = Enum.map(report_data, &(convert_to_integer(&1)))

    expenses
  end

  defp convert_to_integer(my_string) do
    result = Integer.parse(my_string)

    case result do
      {number, _} -> number
      :error -> "It didn't work"
    end
  end

  defp cartesian_product(a, b) do
    for x <- a, y <- b, do: {x, y}
  end

  defp check_sum([head | tail]) do
    case head do
      {x, y} when x + y == 2020 ->
        {:ok, head}
      _ ->
        check_sum(tail)
    end
  end

  defp check_sum([]) do
    {:error, "No matching entries were found"}
  end
end
