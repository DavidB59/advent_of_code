defmodule Day12 do
  def file do
    Parser.read_file("day12")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    list_path = Enum.map(input, &String.split(&1, "-"))
    a_to_b = Enum.group_by(list_path, fn [k, _] -> k end, fn [_, v] -> v end)
    b_to_a = Enum.group_by(list_path, fn [_, k] -> k end, fn [v, _] -> v end)

    Map.merge(a_to_b, b_to_a, fn _k, v1, v2 -> Enum.uniq(v1 ++ v2) end)
  end

  def build_path(input, path \\ [], string \\ "start")
  def build_path(_input, path, "end"), do: {path, :end}

  def build_path(input, path, string) do
    if is_downcase(string) and string in path do
      path
    else
      new_path = [string | path]
      list = Map.get(input, string)

      list
      |> Enum.reject(&(&1 == "start"))
      |> Enum.map(fn string -> build_path(input, new_path, string) end)
    end
  end

  def is_downcase(letter) do
    String.downcase(letter) == letter
  end

  def solve_part_one() do
    file()
    |> parse()
    |> build_path()
    |> List.flatten()
    |> Enum.filter(&is_tuple/1)
    |> Enum.count()
  end

  def solve_part_two() do
    file()
    |> parse()
    |> build_path_two()
    |> List.flatten()
    |> Enum.filter(&is_tuple/1)
    |> Enum.count()
  end

  def build_path_two(input, path \\ [], string \\ "start")
  def build_path_two(_input, path, "end"), do: {path, :end}

  def build_path_two(input, path, string) do
    if is_downcase(string) and string in path do
      new_path = [string | path]
      list = Map.get(input, string)

      list
      |> Enum.reject(&(&1 == "start"))
      |> Enum.map(fn string -> build_path(input, new_path, string) end)
    else
      new_path = [string | path]
      list = Map.get(input, string)

      list
      |> Enum.reject(&(&1 == "start"))
      |> Enum.map(fn string -> build_path_two(input, new_path, string) end)
    end
  end
end
