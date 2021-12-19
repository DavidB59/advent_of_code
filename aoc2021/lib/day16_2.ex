defmodule Day16_2 do
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

  def convert_hexa_to_binary(string) do
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

  def one_packet(packet, list_version \\ [], decoded \\ [])

  def one_packet("", _list_version, decoded), do: decoded

  def one_packet(packet, list_version, decoded) do
    if String.to_integer(packet) == 0 do
      decoded
    else
      {_version, rest} = get_packet_version(packet)
      {packet_id, rest} = get_packet_id(rest)

      {new_value, rest, list_version} =
        if packet_id == 4 do
          convert_packet_id_four(rest, list_version)
        else
          {length_id, rest} = get_length_id(rest)
          get_subpackets(length_id, rest, list_version, packet_id)
        end

      one_packet(rest, list_version, [new_value | decoded])
    end
  end

  def get_subpackets(length_id, string, list_version, packet_id)

  def get_subpackets("0", string, list_version, packet_id) do
    {packet_length, rest} = String.split_at(string, 15)
    packet_length = :erlang.binary_to_integer(packet_length, 2)
    {subpackets, rest} = String.split_at(rest, packet_length)
    decoded = decode_packets_by_length(subpackets, list_version)
    value = calculate(packet_id, decoded)
    {value, rest, list_version}
  end

  def get_subpackets("1", string, list_version, packet_id) do
    {number_of_sub_packets, rest} = String.split_at(string, 11)
    number_of_sub_packets = :erlang.binary_to_integer(number_of_sub_packets, 2)

    {values, rest, list_version} =
      decode_packet_by_numer(rest, number_of_sub_packets, list_version)

    value = calculate(packet_id, values)
    {value, rest, list_version}
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
        convert_packet_id_four(rest, list_version)
      else
        {length_id, rest} = get_length_id(rest)
        get_subpackets(length_id, rest, list_version, packet_id)
      end

    {decoded, rest, list_version}
  end

  def convert_packet_id_four(string, list_version, code \\ "")

  def convert_packet_id_four("1" <> string, list_version, code) do
    {four_bit, rest} = String.split_at(string, 4)
    code = code <> four_bit
    convert_packet_id_four(rest, list_version, code)
  end

  def convert_packet_id_four("0" <> string, list_version, code) do
    {four_bit, rest} = String.split_at(string, 4)

    code = code <> four_bit
    decoded = :erlang.binary_to_integer(code, 2)
    {decoded, rest, list_version}
  end

  def solve_part_one do
    file()
    |> List.first()
    |> convert_hexa_to_binary()
    |> one_packet()
  end

  def calculate(packet_id, sub_packets)

  def calculate(0, sub_packets), do: Enum.sum(sub_packets)

  def calculate(1, sub_packets), do: Enum.reduce(sub_packets, 1, &(&2 * &1))

  def calculate(2, sub_packets), do: Enum.min(sub_packets)

  def calculate(3, sub_packets), do: Enum.max(sub_packets)

  def calculate(5, [one, two]) when one < two, do: 1
  def calculate(5, [_one, _two]), do: 0
  def calculate(5, error), do: IO.inspect(error, label: "error with 5")

  def calculate(6, [one, two]) when one > two, do: 1
  def calculate(6, [_one, _two]), do: 0
  def calculate(6, error), do: IO.inspect(error, label: "error with 6")

  def calculate(7, [equal, equal]), do: 1
  def calculate(7, [_equal, _not_equal]), do: 0
  def calculate(7, error), do: IO.inspect(error, label: "error with 7")
end
