# defmodule Day15_two do
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

#     # recurs(all_distances, 0, nil)

#     # 0..20000
#     # |> Enum.find_value(fn x ->
#     #   IO.inspect(x, label: "x")

#     #   val =
#     #     Enum.find_value(0..20000, fn y ->
#     #       if Enum.all?(all_distances, fn dist -> find_my_spot(dist, {x, y}) end) do
#     #         y
#     #       end
#     #     end)

#     #   if !is_nil(val) do
#     #     {x, val}
#     #   end
#     # end)

#     # {min, max} = borne(file)
#     # min = 0
#     # max = 400_000

#     # # to_be_ =
#     # #   file
#     # #   |> Enum.reduce([], fn [_a, _b, x, y], acc ->
#     # #     if y == y_line do
#     # #       [{x, y} | acc]
#     # #     else
#     # #       acc
#     # #     end
#     # #   end)
#     # #   |> IO.inspect(label: "remove me")

#     # # res =
#     # # occupied =
#     # #   file
#     # #   |> Enum.map(&all_distances/1)
#     # #   |> Enum.reduce(MapSet.new(), fn l1, acc ->
#     # #     no_beacon_spot(l1, {min, max}) |> MapSet.union(acc)
#     # #   end)

#     # all =
#     #   min..max
#     #   |> Enum.reduce(%{}, fn x, acc1 ->
#     #     Enum.reduce(min..max, acc1, fn y, acc2 ->
#     #       Map.put(acc2, {x, y}, 0)
#     #     end)
#     #   end)

#     # MapSet.difference(all, occupied)

#     # Enum.reduce(to_be_removed, res, fn tbd, acc -> MapSet.delete(acc, tbd) end)

#     # |>
#   end

#   def all_distances([x1, y1, x2, y2]) do
#     sb_dist = manhattan_distance({x1, y1}, {x2, y2})
#     {x1, y1, sb_dist}
#   end

#   def find_my_spot({x1, y1, distance}, {x, y}) do
#     manhattan_distance({x, y}, {x1, y1}) > distance
#   end

#   # def no_beacon_spot({x1, y1, distance}, {min, max}, y) do
#   #   IO.inspect({x1, y1}, label: "no beaonc")

#   #   min..max
#   #   |> Enum.reduce(MapSet.new(), fn x, acc ->
#   #     if manhattan_distance({x, y}, {x1, y1}) <= distance do
#   #       MapSet.put(acc, {x, y})
#   #     else
#   #       acc
#   #     end
#   #   end)
#   # end

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
