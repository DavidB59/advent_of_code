defmodule Day21 do
  @p1 4
  @p2 8

  def solve_part_one() do
    play_both(@p1, 0, @p2, 0, 0, 1, 0)
  end

  def new_position(position, dice_result) do
    (position + dice_result) |> Integer.digits() |> List.last()
  end

  def next_die_value(100), do: 1
  def next_die_value(n), do: n + 1

  def roll_one_turn(die_value) do
    die_value_1 = next_die_value(die_value)
    die_value_2 = next_die_value(die_value_1)
    die_value_3 = next_die_value(die_value_2)
    increment = die_value_1 + die_value_2 + die_value_3
    {die_value_3, increment}
  end

  def play(pos1, score1, die_value) do
    {next_die_value, increment} = roll_one_turn(die_value)

    next_pos = (pos1 + increment) |> Integer.digits() |> List.last() |> next_pos()
    next_score = score1 + next_pos
    {next_pos, next_score, next_die_value}
  end

  def next_pos(0), do: 10
  def next_pos(n), do: n

  def play_both(_, score1, _pos2, score2, _die_value, _player_turn, die_rolls)
      when score1 > 999 do
    score2 * die_rolls
  end

  def play_both(_, score1, _pos2, score2, _die_value, _player_turn, die_rolls)
      when score2 > 999 do
    score1 * die_rolls
  end

  def play_both(pos1, score1, pos2, score2, die_value, player_turn, die_rolls) do
    if player_turn == 1 do
      {next_pos, next_score, next_die_value} =
        play(pos1, score1, die_value) |> IO.inspect(label: "score p1")

      play_both(next_pos, next_score, pos2, score2, next_die_value, 2, die_rolls + 3)
    else
      {next_pos, next_score, next_die_value} =
        play(pos2, score2, die_value) |> IO.inspect(label: "score p2")

      play_both(pos1, score1, next_pos, next_score, next_die_value, 1, die_rolls + 3)
    end
  end

  def play_two(_, score1, _pos2, score2, _die_value, _player_turn, die_rolls)
      when score1 > 20 do
    score2 * die_rolls
  end

  def play_two(_, score1, _pos2, score2, _die_value, _player_turn, die_rolls)
      when score2 > 20 do
    score1 * die_rolls
  end

  def play_two(pos1, score1, pos2, score2, die_value, player_turn, die_rolls) do
    if player_turn == 1 do
      {next_pos, next_score, next_die_value} =
        play_2(pos1, score1, die_value) |> IO.inspect(label: "score p1")

      play_two(next_pos, next_score, pos2, score2, next_die_value, 2, die_rolls + 3)
    else
      {next_pos, next_score, next_die_value} =
        play_2(pos2, score2, die_value) |> IO.inspect(label: "score p2")

      play_two(pos1, score1, next_pos, next_score, next_die_value, 1, die_rolls + 3)
    end
  end

  def next_die_value_2(), do: Enum.random([1, 2, 3])

  def roll_one_turn_2() do
    die_value_1 = next_die_value_2()
    die_value_2 = next_die_value_2()
    die_value_3 = next_die_value_2()
    increment = die_value_1 + die_value_2 + die_value_3
    {die_value_3, increment}
  end

  def play_2(pos1, score1, _die_value) do
    {next_die_value, increment} = roll_one_turn_2()

    next_pos = (pos1 + increment) |> Integer.digits() |> List.last() |> next_pos()
    next_score = score1 + next_pos
    {next_pos, next_score, next_die_value}
  end

  def solve_part_two() do
    play_two(@p1, 0, @p2, 0, 0, 1, 0)
  end

  # def find_all_dice_combination_for_player(position, score) do
  #   Enum.map(1..3, fn dice_value ->  )
  # end
  # def dice(sum_three_roll)probabity)
  def dice_sum(3), do: 1 / 27
  def dice_sum(4), do: 3 / 27

  def dice_sum(5), do: 6 / 27

  def dice_sum(6), do: 7 / 27

  def dice_sum(7), do: 6 / 27

  def dice_sum(8), do: 3 / 27

  def dice_sum(9), do: 1 / 27

  def prob_two() do
    one = Enum.map(3..9, &Day21.dice_sum(&1))

    Enum.reduce(one, 0, fn proba, acc ->
      sum1 = Enum.map(one, fn proba2 -> proba * proba2 end) |> Enum.sum()
      acc + sum1
    end)
  end
end
