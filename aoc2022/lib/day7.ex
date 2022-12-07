defmodule Day7 do
  def file do
    Parser.read_file(7)
  end

  def part_one() do
    file()
    |> format()
    |> calculate_dir_size()
    |> elem(1)
    |> Enum.filter(&(&1 < 100_000))
    |> Enum.sum()
  end

  def part_two() do
    {total_used, list_size} =
      file()
      |> format()
      |> calculate_dir_size()

    required_size = required_size(total_used)

    list_size
    |> Enum.filter(&(&1 > required_size))
    |> Enum.min()
  end

  def format(file) do
    build_tree(%{}, file)
  end

  def build_tree(tree, []), do: tree

  def build_tree(tree, [string | rest]) do
    command = string |> String.split(" ") |> determine_kind()

    case command do
      {:dir_name, dirname} ->
        Map.put(tree, {:dir, dirname}, %{}) |> build_tree(rest)

      {:file, {size, filename}} ->
        Map.put(tree, {:file, filename}, String.to_integer(size)) |> build_tree(rest)

      {:go_in_folder, dir_name} ->
        branch = Map.get(tree, {:dir, dir_name})

        case build_tree(branch, rest) do
          {branch, new_rest} ->
            new_tree = tree |> Map.put({:dir, dir_name}, branch)
            build_tree(new_tree, new_rest)

          branch when is_map(branch) ->
            new_tree = tree |> Map.put({:dir, dir_name}, branch)
            build_tree(new_tree, [])
        end

      :back_to_root ->
        build_tree(tree, rest)

      :go_parent_folder ->
        {tree, rest}

      :list_content ->
        build_tree(tree, rest)
    end
  end

  def calculate_dir_size(tree) do
    Enum.reduce(tree, {0, []}, fn {k, v}, {sum, list} ->
      if elem(k, 0) == :dir do
        {size, new_list} = calculate_dir_size(v)
        result = sum + size
        {result, [size | new_list ++ list]}
      else
        {sum + v, list}
      end
    end)
  end

  def required_size(root_size), do: 30_000_000 - (70_000_000 - root_size)

  def determine_kind(["$", "cd", "/"]), do: :back_to_root
  def determine_kind(["$", "ls"]), do: :list_content
  def determine_kind(["dir", dir_name]), do: {:dir_name, dir_name}
  def determine_kind(["$", "cd", ".."]), do: :go_parent_folder
  def determine_kind(["$", "cd", dir_name]), do: {:go_in_folder, dir_name}
  def determine_kind([size, filename]), do: {:file, {size, filename}}
end
