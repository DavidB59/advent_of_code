defmodule Day13 do
  def file do
    Parser.read_file(13)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    file()
    |> format()
    |> Stream.chunk_every(2)
    |> Stream.with_index()
    |> Stream.map(fn {value, index} -> {index, compare(value)} end)
    |> Stream.filter(fn {_index, boolean} -> boolean end)
    |> Stream.map(&elem(&1, 0))
    |> Stream.map(&(&1 + 1))
    |> Enum.sum()
  end

  def part_two() do
    file()
    |> format()
    |> Kernel.++([[[2]], [[6]]])
    |> Enum.sort(&compare_list/2)
    |> Stream.with_index()
    |> Stream.filter(fn {value, _index} -> value == [[2]] || value == [[6]] end)
    |> Stream.map(&elem(&1, 1))
    |> Stream.map(&(&1 + 1))
    |> Enum.product()
  end

  def format(file) do
    file
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&(&1 |> Code.eval_string() |> elem(0)))
  end

  def compare([left, right]) do
    compare_list(left, right)
  end

  # both side run out of items at the same time, continue
  def compare_list([], []) do
    :continue
  end

  # right list run out of items first
  def compare_list(_list, []), do: false

  # left list run out of items first
  def compare_list([], _list), do: true

  # right & left integer and right == left, continue
  def compare_list([head1 | rest1], [head1 | rest2]) when is_integer(head1) do
    compare_list(rest1, rest2)
  end

  # both integer compare and return boolean
  def compare_list([head1 | _rest1], [head2 | _rest2])
      when is_integer(head1) and is_integer(head2) do
    head1 < head2
  end

  # both are list
  def compare_list([head1 | rest1], [head2 | rest2]) when is_list(head1) and is_list(head2) do
    case compare_list(head1, head2) do
      :continue -> compare_list(rest1, rest2)
      result -> result
    end
  end

  # right integer and left a list, convert right to list
  def compare_list([head1 | rest1], [head2 | rest2]) when is_list(head1) and is_integer(head2) do
    new_head2 = [head2]
    compare_list([head1 | rest1], [new_head2 | rest2])
  end

  # left integer and right a list, convert left to list
  def compare_list([head1 | rest1], [head2 | rest2]) when is_integer(head1) and is_list(head2) do
    new_head1 = [head1]
    compare_list([new_head1 | rest1], [head2 | rest2])
  end
end
