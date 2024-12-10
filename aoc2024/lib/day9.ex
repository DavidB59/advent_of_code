defmodule Day9 do
  def file do
    Parser.read_file(9)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
  end

  def solve(input \\ file()) do
    reversed_input =
      input
      |> List.first()
      |> String.to_integer()
      |> Integer.digits()
      |> Enum.reduce({[], 0, :file}, fn
        number, {list, index, :file} ->
          add_to_list = Enum.map(1..number, fn _ -> index end)
          {add_to_list ++ list, index + 1, :memory}

        # no free memory
        0, {list, index, :memory} ->
          {list, index, :file}

        number, {list, index, :memory} ->
          add_to_list = Enum.map(1..number, fn _ -> "." end)
          {add_to_list ++ list, index, :file}
      end)
      |> elem(0)

    file_to_move = reversed_input |> Enum.reject(&(&1 == "."))

    max_file = length(file_to_move)

    reversed_input
    |> Enum.reverse()
    |> move_file(file_to_move, [], 0, max_file)
    |> Enum.reverse()
    |> calculate_checksum()
  end

  def move_file(_, _, result, total, total), do: result

  def move_file(["." | rest], [nb | rest2], new, counter, total) do
    move_file(rest, rest2, [nb | new], counter + 1, total)
  end

  def move_file([head | rest], file_to_move, new, counter, total) do
    move_file(rest, file_to_move, [head | new], counter + 1, total)
  end

  # def move_file([], _, result), do: result

  def calculate_checksum(list_nbs) do
    list_nbs |> Stream.with_index() |> Enum.reduce(0, fn {a, b}, acc -> a * b + acc end)
  end

  def solve_two(input \\ file()) do
    reversed_input =
      input
      |> List.first()
      |> String.to_integer()
      |> Integer.digits()
      |> Enum.reduce({[], 0, :file}, fn
        number, {list, index, :file} ->
          # add_to_list = Enum.map(1..number, fn _ -> index end)
          {[{number, index} | list], index + 1, :memory}

        # no free memory
        0, {list, index, :memory} ->
          {list, index, :file}

        number, {list, index, :memory} ->
          {[
             {number, "."}
             | list
           ], index, :file}
      end)
      |> elem(0)

    # reversed_input
    files_to_move = reversed_input |> Enum.reject(fn {_a, b} -> b == "." end)

    reversed_input
    |> Enum.reverse()
    |> move_entire_file(files_to_move, "")
    |> make_a_string()
    |> check_sum_2()
  end

  def move_entire_file(list, [], _), do: list

  def move_entire_file(list, [first | rest_files], read_file) do
    {file_size, _file_index} = first

    Enum.split_while(list, fn
      {size, "."} -> size < file_size
      _ -> true
    end)
    |> case do
      {list, []} ->
        move_entire_file(list, rest_files, read_file)

      {no_fit, [fit | rest]} ->
        {fit_size, "."} = fit

        tail =
          Enum.split_while(rest, &(&1 != first))
          |> case do
            {before, [^first | after_list]} ->
              before ++ [{file_size, "."}] ++ after_list

            _ ->
              rest -- [first]
          end

        new_list = no_fit ++ [first] ++ [{fit_size - file_size, "."}] ++ tail
        move_entire_file(new_list, rest_files, read_file)
    end
  end

  def make_a_string(list) do
    Enum.reduce(list, {[], []}, fn
      {nb, "."}, {acc, exclude_list} ->
        if nb < 1 do
          {acc, exclude_list}
        else
          to_add = Enum.map(1..nb, fn _ -> "." end)
          {acc ++ to_add, exclude_list}
        end

      {nb, nb_to_add}, {acc, exclude_list} ->
        if nb_to_add in exclude_list do
          to_add = Enum.map(1..nb, fn _ -> "." end)
          {acc ++ to_add, exclude_list}
        else
          to_add = Enum.map(1..nb, fn _ -> nb_to_add end)
          {acc ++ to_add, [nb_to_add | exclude_list]}
        end
    end)
    |> elem(0)
  end

  def check_sum_2(string) do
    string
    |> Stream.with_index()
    # |> Enum.map(& &1)
    |> Enum.reject(fn {a, _b} -> a == "." end)
    |> Enum.reduce(0, fn {a, b}, acc -> a * b + acc end)
  end
end
