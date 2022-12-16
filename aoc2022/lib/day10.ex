defmodule Day10 do
  def file do
    Parser.read_file(10)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    file()
    |> format()
    |> Enum.reduce({%{}, 1, 1}, fn addx_val, {map, x_value, cycle} ->
      # signal strength is current value X cycle numbber
      map = Map.put(map, cycle, x_value * cycle)
      {map, addx_val + x_value, cycle + 1}
    end)
    |> elem(0)
    |> Map.take([20, 60, 100, 140, 180, 220])
    |> Map.values()
    |> Enum.sum()
  end

  def solve_test() do
    test()
    |> format()
  end

  def format(file) do
    file
    |> Enum.map(&duplicate/1)
    |> List.flatten()
  end

  # add a 0 before add x because takes "two" cycle to complete
  # rest does nothing
  def duplicate("addx " <> rest), do: [0, String.to_integer(rest)]
  def duplicate(_), do: [0]

  @spec part_two :: list
  def part_two() do
    file()
    |> format()
    |> recursive()
    |> Enum.reverse()
    |> recompose
  end

  # break the list every 40 to build the "screen"
  def recompose(screen) do
    screen |> Enum.chunk_every(40) |> Enum.map(&Enum.join/1)
  end

  def recursive(instructions, x_value \\ 1, pixel_list \\ [], drawing_pos \\ 0)
  def recursive([], _x_value, pixel_list, _), do: pixel_list

  def recursive([add_x | rest_inst], x_value, pixel_list, drawing_pos) do
    new_x = x_value + add_x
    new_pixel = pixel(drawing_pos, x_value)
    pixel_list = [new_pixel | pixel_list]
    drawing_pos = drawing_pos(drawing_pos)

    recursive(rest_inst, new_x, pixel_list, drawing_pos)
  end

  def pixel(drawing_pos, new_x) do
    if(Enum.member?((new_x - 1)..(new_x + 1), drawing_pos)) do
      "#"
    else
      "."
    end
  end

  # when index = 39, reached end of line,
  # start drawing new line from index 0
  def drawing_pos(drawing_pos) when drawing_pos < 39, do: drawing_pos + 1
  def drawing_pos(39), do: 0
end
