defmodule Day8 do
  def file do
    Parser.read_file(8)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    [instructions, "" | map] = input

    parsed_map = Map.new(map, &format_string/1)
    parsed_instructions = String.graphemes(instructions)
    {parsed_instructions, parsed_map}
  end

  def format_string(
        <<pos1::bytes-size(3)>> <>
          " = (" <> <<left::bytes-size(3)>> <> ", " <> <<right::bytes-size(3)>> <> _
      ) do
    {pos1, {left, right}}
  end

  def solve(input) do
    {instructions, parsed_map} = parse(input)

    follow_instructions(instructions, parsed_map, instructions)
  end

  def solve_two(input) do
    {instructions, parsed_map} = parse(input)

    find_all_starting_positions(parsed_map)
    |> Enum.map(&follow_instructions(instructions, parsed_map, instructions, &1))
    |> Enum.reduce(&RC.lcm/2)
  end

  def follow_instructions(
        instructions,
        map,
        original_instructions,
        current_position \\ "AAA",
        step \\ 0
      )

  def follow_instructions(_, _, _, <<_::bytes-size(2)>> <> "Z", step), do: step

  def follow_instructions([head | rest], map, instructions, current_position, step) do
    new_position = next_position(head, current_position, map)
    follow_instructions(rest, map, instructions, new_position, step + 1)
  end

  def follow_instructions([], map, instructions, current_position, step) do
    follow_instructions(instructions, map, instructions, current_position, step)
  end

  def next_position("R", current_position, map), do: map |> Map.get(current_position) |> elem(1)
  def next_position("L", current_position, map), do: map |> Map.get(current_position) |> elem(0)

  def find_all_starting_positions(map) do
    map |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))
  end

  def stop_if(current_positions), do: Enum.all?(current_positions, &end_with_z/1)

  defp end_with_z(<<_::bytes-size(2)>> <> "Z"), do: true
  defp end_with_z(_), do: false
end
