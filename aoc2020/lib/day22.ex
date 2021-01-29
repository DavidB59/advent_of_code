defmodule Day22 do
  @moduledoc """
  Documentation for day22.
  """

  def part_one() do
    file() |> format() |> solve_one
  end

  def part_two() do
    file() |> format() |> solve_two
  end

  def test() do
    Parser.read_file("test_result") |> format() |> solve_two
  end

  def file() do
    Parser.read_file("day22")
  end

  def solve_two({cards1, cards2}) do
    {_, winner_deck} = recursive_combat(cards1, cards2)
    calculate_score(winner_deck)
  end

  def recursive_combat(deck1, deck2, previous_rounds \\ [])

  def recursive_combat([top1 | rest1] = deck1, [top2] = deck2, previous_rounds) do
    if Enum.member?(previous_rounds, {deck1, deck2}) do
      {:player1_win, deck1}
    else
      {one, two} = high_value_card(top1, top2, rest1, [])

      if two == [] do
        {:player1_win, one}
      else
        previous_rounds = previous_rounds ++ [{deck1, deck2}]
        recursive_combat(one, two, previous_rounds)
      end
    end
  end

  def recursive_combat([top1] = deck1, [top2 | rest2] = deck2, previous_rounds) do
    if Enum.member?(previous_rounds, {deck1, deck2}) do
      {:player1_win, deck1}
    else
      {one, two} = high_value_card(top1, top2, [], rest2)

      if one == [] do
        {:player2_win, two}
      else
        previous_rounds = previous_rounds ++ [{deck1, deck2}]

        recursive_combat(one, two, previous_rounds)
      end
    end
  end

  def recursive_combat([top1 | rest1] = deck1, [top2 | rest2] = deck2, previous_rounds) do
    if Enum.member?(previous_rounds, {deck1, deck2}) do
      {:player1_win, deck1}
    else
      if top1 <= length(rest1) and top2 <= length(rest2) do
        new_deck1 = Enum.slice(rest1, 0..(top1 - 1))
        new_deck2 = Enum.slice(rest2, 0..(top2 - 1))

        case recursive_combat(new_deck1, new_deck2) do
          {:player2_win, _} ->
            next_deck1 = rest1
            next_deck2 = rest2 ++ [top2] ++ [top1]
            previous_rounds = previous_rounds ++ [{deck1, deck2}]
            recursive_combat(next_deck1, next_deck2, previous_rounds)

          {:player1_win, _} ->
            next_deck1 = rest1 ++ [top1] ++ [top2]
            next_deck2 = rest2
            previous_rounds = previous_rounds ++ [{deck1, deck2}]
            recursive_combat(next_deck1, next_deck2, previous_rounds)
        end
      else
        {a, b} = high_value_card(top1, top2, rest1, rest2)

        case {a, b} do
          {[], b} ->
            {:player2_win, b}

          {a, []} ->
            {:player1_win, a}

          {a, b} ->
            previous_rounds = previous_rounds ++ [{deck1, deck2}]
            recursive_combat(a, b, previous_rounds)
        end
      end
    end
  end

  def solve_one({cards1, cards2}) do
    {cards1, cards2}
    winner(cards1, cards2) |> calculate_score()
  end

  def calculate_score(deck_winner) do
    deck_winner
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {card, index} -> {card, index + 1} end)
    |> Enum.reduce(0, fn {card, index}, acc -> card * index + acc end)
  end

  def winner([top1 | rest1], [top2]) do
    {one, two} = high_value_card(top1, top2, rest1, [])

    if two == [] do
      one
    else
      winner(one, two)
    end
  end

  def winner([top1], [top2 | rest2]) do
    {one, two} = high_value_card(top1, top2, [], rest2)

    if one == [] do
      two
    else
      winner(one, two)
    end
  end

  def winner([top1 | rest1], [top2 | rest2]) do
    {one, two} = high_value_card(top1, top2, rest1, rest2)
    winner(one, two)
  end

  def high_value_card(top1, top2, rest1, rest2) do
    if top1 > top2 do
      {rest1 ++ [top1] ++ [top2], rest2}
    else
      {rest1, rest2 ++ [top2] ++ [top1]}
    end
  end

  def format(file) do
    {player1, player2} = Enum.split_while(file, fn x -> x != "Player 2:" end)
    [_head | cards1] = player1
    [_head | cards2] = player2

    {cards1 |> Enum.reject(&(&1 == "")) |> Enum.map(&String.to_integer/1),
     cards2 |> Enum.reject(&(&1 == "")) |> Enum.map(&String.to_integer/1)}
  end
end
