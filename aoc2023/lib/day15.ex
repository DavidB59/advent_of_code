defmodule Day15 do
  def file do
    Parser.read_file(15)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> List.first()
    |> String.split(",")
  end

  def solve(input) do
    input
    |> parse
    |> Enum.map(&run_hash_algorithm/1)
    |> Enum.sum()
  end

  def run_hash_algorithm(current_value \\ 0, string)

  def run_hash_algorithm(current_value, ""), do: current_value

  def run_hash_algorithm(current_value, <<character::bytes-size(1)>> <> rest) do
    character
    |> Utils.character_to_integer()
    |> Kernel.+(current_value)
    |> Kernel.*(17)
    |> rem(256)
    |> run_hash_algorithm(rest)
  end

  def solve_two(input) do
    input
    |> parse
    |> Enum.reduce(%{}, fn string, acc -> determine_instruction(acc, string) end)
    |> calculate_focussing_power()
    |> Enum.sum()
  end

  def calculate_focussing_power(map) do
    Enum.flat_map(map, fn {box_nb, box_content} ->
      box_content
      |> Map.delete(:index)
      |> Map.to_list()
      |> Enum.map(fn {_, b} -> b end)
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.map(&(elem(&1, 0) |> String.to_integer()))
      |> Stream.with_index()
      |> Enum.map(fn {focal_length, index} -> focal_length * (index + 1) * (box_nb + 1) end)
    end)
  end

  def determine_instruction(map, string) do
    {rest, instruction} = String.split_at(string, -1)

    # new_map =
    case instruction do
      "-" -> remove(map, rest)
      _ -> add(map, rest, instruction)
    end
  end

  def add(map, rest, focal_length) do
    label = String.trim(rest, "=")

    box_nb = run_hash_algorithm(label)
    default = %{} |> Map.put(label, {focal_length, 0}) |> Map.put(:index, 1)

    Map.update(map, box_nb, default, fn box_content ->
      case Map.get(box_content, label) do
        {_old_lense, index} ->
          Map.put(box_content, label, {focal_length, index})

        nil ->
          # total = Enum.count(box_content)
          current_index = Map.get(box_content, :index, 0)

          Map.put(box_content, label, {focal_length, current_index})
          |> Map.put(:index, current_index + 1)
      end
    end)
  end

  def remove(map, label) do
    box_nb = run_hash_algorithm(label)

    Map.update(map, box_nb, %{}, fn box_content ->
      if Map.has_key?(box_content, label) do
        box_content
        |> Map.delete(label)

        # |> Map.update(:index, 0, fn index ->
        #   if index == 0, do: 0, else: index - 1
        # end)
      else
        box_content
      end
    end)
  end
end
