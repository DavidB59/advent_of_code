# defmodule Day15 do
#   # guess 3703676
#   # guess 3703316
#   # 3704276

#   # TBG 4231375
#   # TBG 4681485

#   @min 0
#   @max 20
#   def file do
#     Parser.read_file(15)
#   end

#   def test do
#     Parser.read_file("test")
#   end

#   def part_one() do
#     file()
#     |> format()
#     |> solve(2_000_000)
#   end

#   def solve_test do
#     test()
#     |> format()
#     |> solve(10)

#     # |> Enum.filter(fn {{_x, y}, _val} -> y == 10 end)
#     # |> Enum.count()
#   end

#   def solve(file, _y_line) do
#     all_distances =
#       file
#       |> Enum.map(&all_distances/1)

#     # possible_points = all_distances |> List.first() |> find_possible_point_for_sensor()
#   end

#   def find_possible_point_for_sensor({x1, y1, distance}) do
#     # outside_box
#     # range1 = x1 + distance
#   end

#   def inner_box({x1, y1, distance}) do
#     range = (distance * :math.sqrt(2) / 2) |> Kernel.trunc()
#     x_range = x1..(x1 + range)
#   end

#   def all_distances([x1, y1, x2, y2]) do
#     sb_dist = manhattan_distance({x1, y1}, {x2, y2})
#     {x1, y1, sb_dist}
#   end

#   def find_my_spot({x1, y1, distance}, {x, y}) do
#     manhattan_distance({x, y}, {x1, y1}) > distance
#   end

#   def format(file) do
#     file
#     |> Enum.map(fn string ->
#       string
#       |> String.split("=")
#       |> Enum.map(fn string ->
#         if String.contains?(string, "-") do
#           val = Utils.extract_number_from_string(string) |> String.to_integer()
#           val - val - val
#         else
#           case Utils.extract_number_from_string(string) do
#             "" -> nil
#             val -> String.to_integer(val)
#           end
#         end
#       end)
#       |> Enum.reject(&(&1 == nil))
#     end)
#   end

#   def manhattan_distance({x1, y1}, {x2, y2}) do
#     abs(x1 - x2) + abs(y1 - y2)
#   end

#   def borne(list) do
#     flat = list |> Enum.map(fn [x1, _y1, x2, _y2] -> [x1, x2] end) |> List.flatten()
#     {Enum.min(flat), Enum.max(flat)}
#   end
# end
