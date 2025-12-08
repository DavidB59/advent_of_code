defmodule Day8 do
  def file, do: Parser.read_file(8)
  def test, do: Parser.read_file("test")

  # todo 1 - reneable part 1 so that can run both part
  # todo 2 - maybe check using mapset
  def parse(input) do
    input
    |> Enum.map(fn a -> a |> String.split(",") |> Enum.map(&String.to_integer/1) end)
  end

  def part_one(input \\ test()) do
    input
    |> parse()
    |> all_distances()
    |> Enum.sort(fn a, b -> elem(a, 2) <= elem(b, 2) end)
    |> connect_boxes([], 0)

    # |> Enum.sort(&(length(&1) >= length(&2)))
    # |> Enum.take(3)
    # |> Enum.map(&length/1)
    # |> Enum.product()
  end

  @spec part_two(any()) :: any()
  def part_two(input \\ test()) do
    input
  end

  # def connect_boxes(_list, circuits_list, 1000), do: circuits_list
  # def connect_boxes([last], _, _), do: last

  def connect_boxes([closest | rest], circuits_list, counter) do
    IO.inspect(counter, label: "counter")
    # IO.inspect(Enum.min_by(list, &elem(&1, 2)), label: "min")

    {a, b, _distance} = closest

    # check if a is already in a circuit
    circuit_a = Enum.find(circuits_list, &Enum.member?(&1, a))

    # check if b is already in a circuit
    circuit_b = Enum.find(circuits_list, &Enum.member?(&1, b))

    new_result =
      cond do
        # none of them already in a circuit
        # create a new one
        is_nil(circuit_a) and is_nil(circuit_b) ->
          new_result = [[a, b] | circuits_list]

        # connect_boxes(rest, new_result, counter + 1)

        is_nil(circuit_a) ->
          # connec to circuit_b
          new_circuit_b = [a | circuit_b]
          circuit_1 = circuits_list |> List.delete(circuit_b)
          new_result = [new_circuit_b | circuit_1]

        # connect_boxes(rest, new_result, counter + 1)

        is_nil(circuit_b) ->
          # connec to circuit_a
          new_circuit_a = [b | circuit_a]
          circuit_1 = circuits_list |> List.delete(circuit_a)
          new_result = [new_circuit_a | circuit_1]

        # connect_boxes(rest, new_result, counter + 1)

        # points in the same circuit
        # nothing happen, don't increase counter
        circuit_a == circuit_b ->
          circuits_list

        # connect_boxes(rest, circuits_list, counter + 1)

        # circuit a and b exists but are different
        # idea 1, mege them, doesn't work
        # idea 2, don't merge them skip and continue, also does not work
        true ->
          merged = circuit_a ++ circuit_b
          circuit_1 = circuits_list |> List.delete(circuit_a) |> List.delete(circuit_b)
          new_result = [merged | circuit_1]
          # connect_boxes(rest, new_result, counter + 1)
      end

    if new_result |> List.first() |> Enum.count() == 1000 do
      {a, b}
    else
      connect_boxes(rest, new_result, counter + 1)
    end
  end

  def all_distances(points) do
    for i <- points,
        j <- points do
      {i, j, distance(i, j)}
    end
    |> Enum.reject(&(elem(&1, 2) == 0.0))
    |> Enum.uniq_by(fn {_a, _b, distance} -> distance end)
  end

  def distance([x1, y1, z1], [x2, y2, z2]) do
    (:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2) + :math.pow(z2 - z1, 2))
    |> :math.sqrt()
  end
end
