defmodule Day22 do
  def file, do: Parser.read_file("day22")
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn string ->
      [instruction, range] = string |> String.split(" ")

      range =
        range
        |> String.split(",")
        |> Enum.map(fn string ->
          [a, b] =
            string
            |> String.split_at(2)
            |> elem(1)
            |> String.split("..")
            |> Enum.map(&String.to_integer/1)

          MapSet.new(a..b)
        end)
        |> to_map_set

      {instruction, range}
    end)
  end

  def turn_cube_on({instruction, [x_range, y_range, z_range]}, map_cube) do
    IO.inspect({instruction, [x_range, y_range, z_range]})

    Enum.reduce(x_range, map_cube, fn
      x, map_cube when x in -50..50 ->
        Enum.reduce(y_range, map_cube, fn
          y, map_cube when y in -50..50 ->
            Enum.reduce(z_range, map_cube, fn
              z, map_cube when z in -50..50 ->
                case Map.get(map_cube, {x, y, z}) do
                  nil -> map_cube
                  _ -> Map.put(map_cube, {x, y, z}, instruction)
                end

              _, map_cube ->
                map_cube
            end)

          _, map_cube ->
            map_cube
        end)

      _, map_cube ->
        map_cube
    end)
  end

  def apply_instructions(instruction_lists) do
    Enum.reduce(instruction_lists, MapSet.new(), &turn_cube_on(&1, &2))
  end

  def to_map_set([x_range, y_range, z_range]) do
    Enum.reduce(x_range, MapSet.new(), fn x, map_cube ->
      Enum.reduce(y_range, map_cube, fn y, map_cube ->
        Enum.reduce(z_range, map_cube, fn z, map_cube ->
          MapSet.put(map_cube, {x, y, z})
        end)
      end)
    end)
  end

  def solve_part_one() do
    instruction_list = file() |> parse()

    apply_instructions(instruction_list)
    |> Map.values()
    |> Enum.filter(&(&1 == "on"))
    |> Enum.count()
  end
end
