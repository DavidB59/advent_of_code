defmodule Day19 do
  @cache_name :visited
  # manhatten distance = good idea
  # use BFS
  # start from E
  def file do
    Parser.read_file(19)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    [towels | designs] =
      input
      |> Enum.reject(&(&1 == ""))

    towels = towels |> String.split(", ")
    {towels, designs}
  end

  def solve(input \\ file()) do
    {towels, designs} =
      input
      |> parse()

    Enum.map(designs, fn design ->
      towel_to_consider = Enum.filter(towels, &String.contains?(design, &1))
      is_design_possible(towel_to_consider, design)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.count()
  end

  def string_pattern_match(towel, design) do
    case design do
      ^towel <> rest -> {rest, towel}
      _ -> false
    end
  end

  def is_design_possible(towels, design) do
    new_list =
      towels
      |> Enum.map(fn towel ->
        string_pattern_match(towel, design)
      end)
      |> Enum.filter(& &1)

    if Enum.any?(new_list, &(&1 == "")) do
      true
    else
      Enum.find(new_list, fn trimmed_design -> is_design_possible(towels, trimmed_design) end)
    end
  end

  def find_all_possible_design_two(towels, design, acc \\ "")

  def find_all_possible_design_two(_towels, "", acc) do
    [acc]
  end

  def find_all_possible_design_two(towels, design, acc) do
    case :ets.lookup(@cache_name, design) do
      [{_key, _result}] ->
        IO.inspect(design, label: "CACHED")
        [acc]

      _ ->
        new_list =
          towels
          |> Enum.map(fn towel ->
            string_pattern_match(towel, design)
          end)
          |> Enum.filter(& &1)

        Enum.flat_map(new_list, fn {trimmed_design, used_towel} ->
          does_work = acc <> used_towel
          :ets.insert(@cache_name, {does_work, true})
          find_all_possible_design_two(towels, trimmed_design, does_work)
        end)
    end
  end

  @spec solve_two(any()) :: non_neg_integer()
  @spec solve_two(any()) :: non_neg_integer()
  def solve_two(input \\ file()) do
    cache()

    {towels, designs} =
      input
      |> parse()

    designs
    |> Stream.with_index()
    |> Enum.map(fn {design, index} ->
      IO.inspect(index, label: "design nb")
      towel_to_consider = Enum.filter(towels, &String.contains?(design, &1))

      find_all_possible_design_two(towel_to_consider, design) |> Enum.count()
    end)

    # |> List.flatten()
    # |> Enum.count()
  end

  def cache do
    if :ets.whereis(@cache_name) != :undefined do
      :ets.delete(@cache_name)
    end

    :ets.new(@cache_name, [:named_table])
  end
end
