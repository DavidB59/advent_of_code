defmodule Day16 do
  def file do
    Parser.read_file("day16")
  end

  def test do
    Parser.read_file("test")
  end

  def hexa_to_binary("0"), do: "0000"
  def hexa_to_binary("1"), do: "0001"
  def hexa_to_binary("2"), do: "0010"
  def hexa_to_binary("3"), do: "0011"
  def hexa_to_binary("4"), do: "0100"
  def hexa_to_binary("5"), do: "0101"
  def hexa_to_binary("6"), do: "0110"
  def hexa_to_binary("7"), do: "0111"
  def hexa_to_binary("8"), do: "1000"
  def hexa_to_binary("9"), do: "1001"
  def hexa_to_binary("A"), do: "1010"
  def hexa_to_binary("B"), do: "1011"
  def hexa_to_binary("C"), do: "1100"
  def hexa_to_binary("D"), do: "1101"
  def hexa_to_binary("E"), do: "1110"
  def hexa_to_binary("F"), do: "1111"

  def convert_hext_to_binary(string) do
    string
    |> String.graphemes()
    |> Enum.map(&hexa_to_binary/1)
    |> Enum.reduce(&(&2 <> &1))
  end

  def get_packet_version(string) do
    {packet_version, rest} = String.split_at(string, 3)
    hexa_packet_version = :erlang.binary_to_integer(packet_version, 2)
    {hexa_packet_version, rest}
  end

  def get_packet_id(string) do
    {packet_id, rest} = String.split_at(string, 3)
    hexa_packet_id = :erlang.binary_to_integer(packet_id, 2)
    {hexa_packet_id, rest}
  end

  def get_length_id(string) do
    {length_id, rest} = String.split_at(string, 1)
    {length_id, rest}
  end

  def decoder(packet) do
    binary = packet |> convert_hext_to_binary()

    one_packet(binary)
  end

  def one_packet(packet, list_version \\ [])

  def one_packet("", list_version) do
    list_version
  end

  def one_packet(packet, list_version) do
    if String.to_integer(packet) == 0 do
      list_version
    else
      {version, rest} = get_packet_version(packet)

      {packet_id, rest} = get_packet_id(rest)

      list_version = [version | list_version]

      {decoded, rest, list_version} =
        if packet_id == 4 do
          convert_packet_id_four(rest, "", list_version)
        else
          {length_id, rest} = get_length_id(rest)
          get_subpackets(length_id, rest, list_version, packet_id)
        end

      one_packet(rest, list_version)
    end
  end

  def get_subpackets(length_id, string, list_version, packet_id)

  def get_subpackets("0", string, list_version, packet_id) do
    {packet_length, rest} = String.split_at(string, 15)
    packet_length = :erlang.binary_to_integer(packet_length, 2)
    {subpackets, rest} = String.split_at(rest, packet_length)
    list_version = decode_packets_by_length(subpackets, list_version)

    {"decoded", rest, list_version}
  end

  def get_subpackets("1", string, list_version, packet_id) do
    {number_of_sub_packets, rest} = String.split_at(string, 11)
    number_of_sub_packets = :erlang.binary_to_integer(number_of_sub_packets, 2)
    decode_packet_by_numer(rest, number_of_sub_packets, list_version)
  end

  def decode_packets_by_length(subpackets, list_version) do
    one_packet(subpackets, list_version)
  end

  def decode_packet_by_numer(subpackets, number, list_version) do
    Enum.reduce(1..number, {[], subpackets, list_version}, fn _,
                                                              {decoded_list, rest, list_version} ->
      {decoded, rest, version} = one_packet_reducer(rest)
      {[decoded | decoded_list], rest, [version | list_version]}
    end)
  end

  def one_packet_reducer(packet) do
    {version, rest} = get_packet_version(packet)
    {packet_id, rest} = get_packet_id(rest)
    list_version = [version]

    {decoded, rest, list_version} =
      if packet_id == 4 do
        convert_packet_id_four(rest, "", list_version)
      else
        {length_id, rest} = get_length_id(rest)
        get_subpackets(length_id, rest, list_version, packet_id)
      end

    {decoded, rest, list_version}
  end

  def convert_packet_id_four("1" <> string, code, list_version) do
    {four_bit, rest} = String.split_at(string, 4)
    code = code <> four_bit
    convert_packet_id_four(rest, code, list_version)
  end

  def convert_packet_id_four("0" <> string, code, list_version) do
    {four_bit, rest} = String.split_at(string, 4)

    code = code <> four_bit
    decoded = :erlang.binary_to_integer(code, 2)
    {decoded, rest, list_version}
  end

  def solve_part_one do
    file() |> List.first() |> decoder() |> List.flatten() |> Enum.sum()
  end
end
