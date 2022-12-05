defmodule Day5 do
  def file do
    Parser.read_file("day5")
  end

  def part_one do
    file()
    |> format_instruction()
    |> move_crates(crate_map(), &move_crates_one_by_one/3)
    |> get_top_crates()
  end

  def part_two do
    file()
    |> format_instruction()
    |> move_crates(crate_map(), &move_crates_by_group/3)
    |> get_top_crates()
  end

  defp format_instruction(file) do
    Enum.map(file, fn string ->
      [_, amount, _, source, _, target] = String.split(string, " ")
      [String.to_integer(amount), source, target]
    end)
  end

  defp move_crates(instructions, crate_map, crate_function) do
    Enum.reduce(instructions, crate_map, fn [amount, source, target], acc ->
      source_string = Map.get(acc, source)
      target_string = Map.get(acc, target)
      {nsource, ntarget} = crate_function.(source_string, target_string, amount)

      acc
      |> Map.put(source, nsource)
      |> Map.put(target, ntarget)
    end)
  end

  defp move_crates_by_group(source, target, amount) do
    <<one::bytes-size(amount)>> <> rest = source
    target = one <> target
    {rest, target}
  end

  defp move_crates_one_by_one(source, target, 0), do: {source, target}

  defp move_crates_one_by_one(source, target, amount) do
    <<one::bytes-size(1)>> <> rest = source
    target = one <> target
    move_crates_one_by_one(rest, target, amount - 1)
  end

  defp get_top_crates(map) do
    map
    |> Map.values()
    |> Enum.map(&String.first/1)
    |> Enum.join("")
  end

  # [B]                     [N]     [H]
  # [V]         [P] [T]     [V]     [P]
  # [W]     [C] [T] [S]     [H]     [N]
  # [T]     [J] [Z] [M] [N] [F]     [L]
  # [Q]     [W] [N] [J] [T] [Q] [R] [B]
  # [N] [B] [Q] [R] [V] [F] [D] [F] [M]
  # [H] [W] [S] [J] [P] [W] [L] [P] [S]
  # [D] [D] [T] [F] [G] [B] [B] [H] [Z]
  #  1   2   3   4   5   6   7   8   9

  defp crate_map do
    %{
      "1" => "BCWTQNHD",
      "2" => "BWD",
      "3" => "CJWQST",
      "4" => "PTZNRJF",
      "5" => "TSMJVPG",
      "6" => "NTFWB",
      "7" => "NVHFQDLB",
      "8" => "RFPH",
      "9" => "HPNLBMSZ"
    }
  end
end
