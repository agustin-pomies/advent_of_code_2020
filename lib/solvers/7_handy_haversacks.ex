defmodule HandyHaversacks do
  def get_data do
    IOModule.get_input("7") |> parse_input()
  end

  def part_one do
    get_data()
    |> build_graph()
    |> Graph.reaching_neighbors([color_bag()])
    |> length()
  end

  def part_two do
    g = get_data() |> build_graph()
    reachable_vertices = Graph.reachable(g, [color_bag()])

    Graph.subgraph(g, reachable_vertices)
    |> travel_graph(color_bag())
    |> Kernel.-(1)
  end

  def travel_graph(g, vertex) do
    Graph.out_edges(g, vertex)
    |> Enum.map(&(Map.take(&1, [:v2, :weight])))
    |> Enum.reduce(1, fn %{v2: color_bag, weight: weight}, acc -> acc + weight * travel_graph(g, color_bag) end)
  end

  def parse_input(sentences) do
    sentences
    |> Enum.map(&(parse_sentence(&1)))
    |> Enum.reduce(fn elem, acc -> Map.merge(acc, elem) end)
  end

  def parse_sentence(sentence) do
    [bag_color | [parsed_sentence]] = 
      String.replace(sentence, ".", "")
      |> String.split(" bags contain ")

    contained_bags =
      parsed_sentence
      |> String.split(", ")
      |> Enum.map(&(parse_contained_bag(&1)))
    
    %{bag_color => contained_bags}
  end

  def parse_contained_bag(bag_contained_sentence) do
    regex = ~r/^([[:digit:]]+) ([[:alpha:]]+ [[:alpha:]]+)/

    case Regex.scan(regex, bag_contained_sentence) do
      [] -> %{}
      [[_full_match, weight, color_contained]] -> {color_contained, weight: Helper.to_integer(weight)}
    end
  end

  def parse_edges(_color_bag, [%{}]) do
    []
  end

  def parse_edges(color_bag, contained) do
    result = Enum.map(
      contained,
      &((fn {color_contained, weight: b} -> {color_bag, color_contained, weight: b} end).(&1))
    )

    result
  end
  
  def build_graph(mapping) do
    g = Graph.new
    g = Graph.add_vertices(g, Map.keys(mapping))
    Enum.reduce(mapping, g, fn {color_bag, contained}, acc -> Graph.add_edges(acc, parse_edges(color_bag, contained)) end)
  end

  def color_bag do
    "shiny gold"
  end
end
