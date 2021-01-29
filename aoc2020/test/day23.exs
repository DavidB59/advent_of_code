defmodule Day23Test do
  import Day23
  use ExUnit.Case

  test "after_two_move" do
    one_move = "389125467" |> format() |> solve_one(2)

    assert one_move ==
             " 2 8  9  1  5  4  6  7 3 "
             |> String.trim()
             |> String.graphemes()
             |> Enum.reject(&(&1 == " "))
  end

  test "after_three_move" do
    one_move = "389125467" |> format() |> solve_one(2)

    assert one_move ==
             "5 4  6  7  8  9  1 3  2 "
             |> String.trim()
             |> String.graphemes()
             |> Enum.reject(&(&1 == " "))
  end
end
