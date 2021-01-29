# defmodule AocTest do
#   use ExUnit.Case
#   import Day23

#   doctest Aoc

#   test "greets the world" do
#     assert Aoc.hello() == :world
#   end

#   test "after_two_move" do
#     one_move = "389125467" |> format() |> recursive_head(1)

#     assert one_move ==
#              "2 8  9  1  5  4  6  7 3"
#              |> String.trim()
#              |> String.graphemes()
#              |> Enum.reject(&(&1 == " "))
#              |> Enum.map(&String.to_integer/1)
#   end

#   test "after_three_move" do
#     one_move = "389125467" |> format() |> recursive_head(2)

#     assert one_move ==
#              " 5 4  6  7  8  9  1 3 2 "
#              |> String.trim()
#              |> String.graphemes()
#              |> Enum.reject(&(&1 == " "))
#              |> Enum.map(&String.to_integer/1)
#   end

#   test "after_six_move" do
#     one_move = "389125467" |> format() |> recursive_head(5)

#     assert one_move ==
#              "1 3  6  7 9  2  5  8  4 "
#              |> String.trim()
#              |> String.graphemes()
#              |> Enum.reject(&(&1 == " "))
#              |> Enum.map(&String.to_integer/1)
#   end

#   test "after_10_move" do
#     one_move = "389125467" |> format() |> recursive_head(9)

#     assert one_move ==
#              "5 7  4  1  8  3  9  2  6 "
#              |> String.trim()
#              |> String.graphemes()
#              |> Enum.reject(&(&1 == " "))
#              |> Enum.map(&String.to_integer/1)
#   end
# end
