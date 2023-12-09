defmodule Day7 do
  def file do
    Parser.read_file(7)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      [a, b] = String.split(string)
      {a |> String.graphemes(), String.to_integer(b)}
    end)
  end

  def solve(input) do
    input
    |> parse()
    |> Enum.sort(fn {hand_a, _}, {hand_b, _} ->
      {index, _type} = PokerBb.winner(hand_a, hand_b)

      if index == 1 do
        false
      else
        true
      end
    end)
    |> Enum.map(&elem(&1, 1))
    |> Stream.with_index()
    |> Enum.reduce(0, fn {a, b}, acc ->
      a * (b + 1) + acc
    end)
  end

  def solve_two(input) do
    input
    |> parse()
    |> Enum.sort(fn {hand_a, _}, {hand_b, _} ->
      {index, _type} = PokerBbJoker.winner(hand_a, hand_b)

      if index == 1 do
        false
      else
        true
      end
    end)
    |> Enum.map(&elem(&1, 1))
    |> Stream.with_index()
    |> Enum.reduce(0, fn {a, b}, acc ->
      a * (b + 1) + acc
    end)
  end
end
