defmodule Day9 do
  @accumulator {MapSet.new(), %{head: {0, 0}, tail: {0, 0}}}

  @tail Map.new(1..9, fn n -> {n, {0, 0}} end)
  @accumulator_two {MapSet.new(), %{head: {0, 0}, tail: @tail}}

  def file do
    Parser.read_file(9)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    file()
    |> format()
    |> Enum.reduce(@accumulator, &reduce/2)
    |> elem(0)
    |> MapSet.size()
  end

  def part_two() do
    file()
    |> format()
    |> Enum.reduce(@accumulator_two, &reducer_part_two/2)
    |> elem(0)
    |> MapSet.size()
  end

  def format(file) do
    file
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [dir, move] -> {dir, String.to_integer(move)} end)
    |> Enum.map(&split_instruction/1)
    |> List.flatten()
  end

  def split_instruction({_, 1} = ins), do: ins
  def split_instruction({dir, movement}), do: Enum.map(1..movement, fn _ -> {dir, 1} end)

  def reduce(instruction, {visited_pos, %{head: head_pos, tail: tail_pos}}) do
    new_head_pos = move_head(instruction, head_pos)
    new_tail_pos = should_move_tail(tail_pos, new_head_pos)

    acc1 = MapSet.put(visited_pos, new_tail_pos)
    {acc1, %{head: new_head_pos, tail: new_tail_pos}}
  end

  def reducer_part_two(instruction, {visited_pos, %{head: head_pos, tail: tail}}) do
    new_head_pos = move_head(instruction, head_pos)

    new_tail =
      Enum.reduce(tail, tail, fn
        {k, tail_pos}, acc ->
          pos1 = Map.get(acc, k - 1, new_head_pos)
          new_tail_pos = should_move_tail(tail_pos, pos1)
          Map.put(acc, k, new_tail_pos)
      end)

    acc1 = MapSet.put(visited_pos, Map.get(new_tail, 9))
    {acc1, %{head: new_head_pos, tail: new_tail}}
  end

  def move_head({"L", movement}, {x, y}), do: {x - movement, y}
  def move_head({"R", movement}, {x, y}), do: {x + movement, y}

  def move_head({"U", movement}, {x, y}), do: {x, y + movement}
  def move_head({"D", movement}, {x, y}), do: {x, y - movement}

  def should_move_tail({x_tail, y_tail}, {x_head, y_head}) do
    diff_x = abs(x_tail - x_head)
    diff_y = abs(y_tail - y_head)

    if diff_x <= 1 and diff_y <= 1 do
      {x_tail, y_tail}
    else
      move_tail({x_tail, y_tail}, {x_head, y_head})
    end
  end

  def move_tail({x, y_tail}, {x, y_head}) when y_tail > y_head, do: {x, y_head + 1}
  def move_tail({x, y_tail}, {x, y_head}) when y_tail < y_head, do: {x, y_head - 1}
  def move_tail({x_tail, y}, {x_head, y}) when x_tail < x_head, do: {x_head - 1, y}
  def move_tail({x_tail, y}, {x_head, y}) when x_tail > x_head, do: {x_head + 1, y}
  # diagonal
  def move_tail({x_tail, y_tail}, {x_head, y_head}) do
    {diagonal(x_tail, x_head), diagonal(y_tail, y_head)}
  end

  def diagonal(tail_pos, head_pos) when tail_pos > head_pos, do: tail_pos - 1
  def diagonal(tail_pos, head_pos) when tail_pos < head_pos, do: tail_pos + 1
end
