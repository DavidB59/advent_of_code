defmodule Day3 do
  def file do
    Parser.read_file(3)
    # Parser.read_file("test")
  end

  def format do
    file()
    |> Enum.map(fn string ->
      [id, _, offset, size] = String.split(string, " ")

      [x_offset, y_offset] =
        offset |> String.trim(":") |> String.split(",") |> Enum.map(&String.to_integer/1)

      [x_size, y_size] = String.split(size, "x") |> Enum.map(&String.to_integer/1)

      {id, {x_offset, y_offset}, {x_size, y_size}}
    end)
  end

  def part_one() do
    format()
    |> Enum.reduce(%{}, fn {_, {x_offset, y_offset}, {x_size, y_size}}, acc ->
      Enum.reduce(x_offset..(x_offset + x_size - 1), acc, fn x, acc ->
        Enum.reduce(y_offset..(y_offset + y_size - 1), acc, fn y, acc ->
          {x, y}

          case Map.get(acc, {x, y}) do
            nil -> Map.put(acc, {x, y}, 1)
            val -> Map.put(acc, {x, y}, val + 1)
          end
        end)
      end)
    end)
    |> Map.values()
    |> Enum.filter(&(&1 > 1))
    |> Enum.count()
  end

  def part_two do
    list = format()

    overlap =
      list
      |> Enum.reduce(%{}, fn {_, {x_offset, y_offset}, {x_size, y_size}}, acc ->
        Enum.reduce(x_offset..(x_offset + x_size - 1), acc, fn x, acc ->
          Enum.reduce(y_offset..(y_offset + y_size - 1), acc, fn y, acc ->
            {x, y}

            case Map.get(acc, {x, y}) do
              nil -> Map.put(acc, {x, y}, 1)
              val -> Map.put(acc, {x, y}, val + 1)
            end
          end)
        end)
      end)
      |> Enum.filter(fn {_key, value} -> value > 1 end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    list
    |> Enum.find(fn {_, {x_offset, y_offset}, {x_size, y_size}} ->
      mapset =
        Enum.reduce(x_offset..(x_offset + x_size - 1), MapSet.new(), fn x, acc ->
          Enum.reduce(y_offset..(y_offset + y_size - 1), acc, fn y, acc ->
            MapSet.put(acc, {x, y})
          end)
        end)

      MapSet.disjoint?(overlap, mapset)
    end)
  end
end
