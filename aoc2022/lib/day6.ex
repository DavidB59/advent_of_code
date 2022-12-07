defmodule Day6 do
  def file do
    Parser.read_file(6)
  end

  def part_one() do
    file()
    |> List.first()
    |> find_unique_packet(4)
  end

  def part_two() do
    file()
    |> List.first()
    |> find_unique_packet(14)
  end

  def find_unique_packet(string, index \\ 0, packet_size) do
    {packet, _} = Utils.string_pattern_match(string, packet_size)
    mapset = packet |> String.codepoints() |> MapSet.new()

    if MapSet.size(mapset) == packet_size do
      index + packet_size
    else
      {_, rest} = Utils.string_pattern_match(string, 1)

      find_unique_packet(rest, index + 1, packet_size)
    end
  end
end
