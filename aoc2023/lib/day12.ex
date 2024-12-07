defmodule Day12 do
  def file do
    Parser.read_file("day12")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      [sources, group_of_broken_sources] = String.split(string)
      b = group_of_broken_sources |> String.split(",") |> Enum.map(&String.to_integer/1)
      {sources, b}
    end)
  end

  def filter(list, pipe_groupe, constraint) do
    order_is_respected(list, pipe_groupe) and no_consecutive_broken_pipe(list) and
      match_constraint(list, constraint)
  end

  def match_constraint(list, constraint) do
    string = list |> Enum.join()
    #  |> IO.inspect()
    regex = constraint |> String.replace("?", ".") |> Regex.compile!()
    # IO.inspect(constraint, label: "const")
    String.match?(string, regex)
  end

  def no_consecutive_broken_pipe(list) do
    result =
      Enum.reduce_while(list, ".", fn character, previous ->
        if String.contains?(character, "#") and String.contains?(previous, "#") do
          {:halt, false}
        else
          {:cont, character}
        end
      end)

    if result, do: true, else: false
  end

  def order_is_respected(list, constraints) do
    list |> Enum.reject(&(&1 == ".")) |> Enum.map(&String.length/1) == constraints
  end

  def solve(input) do
    input
    |> parse()
    |> Stream.with_index()
    |> Enum.map(fn {string, index} ->
      IO.inspect(index)
      solve_one_line(string)
    end)
    |> Enum.map(fn list -> Enum.reduce(list, fn a, acc -> a * acc end) end)
    |> Enum.sum()
  end

  def input_test do
    {"??????.#?####?#?#??#", [1, 1, 1, 6, 2, 1]}
  end

  @spec solve_one_line({any(), any()}, any()) :: any()
  def solve_one_line(tuple_string_constraint, possiblites \\ [1], reverse? \\ false)

  def solve_one_line({nil, _list}, poss, _) do
    poss
  end

  def solve_one_line({<<>>, []}, poss, _), do: poss

  def solve_one_line({"", _list}, poss, _) do
    poss
  end

  def solve_one_line({_string, []}, poss, _) do
    poss
  end

  def solve_one_line({"." <> rest, instructions}, possibilities, _),
    do: solve_one_line({rest, instructions}, possibilities)

  def solve_one_line({string, instructions}, possibilities, reverse?) do
    # IO.inspect(string, label: "String")
    # # # IO.inspect(String.length(string), label: "string lenght")
    # IO.inspect(instructions, label: "instructions start")
    # IO.inspect(possibilities, label: "possibilites")

    [first_instruction | rest] = instructions

    pattern = 1..first_instruction |> Enum.reduce("", fn _, acc -> "#" <> acc end)

    {index, group, type} =
      Enum.reduce_while(0..(String.length(string) - 1), {0, [], :start}, fn index,
                                                                            {_old_index, acc,
                                                                             _atom} ->
        new = String.at(string, index)
        new_acc = acc ++ [new]

        cond do
          new == "." ->
            {:halt, {index, acc, :end_of_group}}

          # Enum.count(new_acc) == first_instruction and Enum.all?(new_acc, &(&1 == "#")) ->
          #   {:halt, {index, new_acc, :instruction_match}}

          # Enum.member?(new_acc, "#") and Enum.count(new_acc) == first_instruction + 1 ->
          #   {:halt, {index, new_acc, :instruction_match_with_one_replace}}

          # acc |> Enum.join() |> String.contains?(pattern) ->
          #   {:halt, {index, acc, :instruction_match_with_replace}}

          # Enum.count(new_acc) >= count ->
          #   {:halt, {index, :need_handling}}

          true ->
            {:cont, {index, new_acc, :reduced_till_the_end}}
        end
      end)

    # |> IO.inspect(label: "OUTPUT")

    start_or_finish_with_diese? = List.first(group) == "#" || List.last(group) == "#"

    cond do
      # Enum.count(group) == first_instruction ->
      #   new_string = String.slice(string, index..String.length(string))
      #   solve_one_line({new_string, rest}, possibilities)

      !start_or_finish_with_diese? and Enum.count(group) == first_instruction + 1 ->
        to_slice = Enum.count(group)
        new_string = String.slice(string, to_slice..String.length(string))
        solve_one_line({new_string, rest}, [2 | possibilities])

      type != :instruction_match_with_replace and start_or_finish_with_diese? and
        Enum.count(group) == first_instruction + 1 and Enum.all?(group, &(&1 == "?")) ->
        new_string = String.slice(string, index..String.length(string))
        solve_one_line({new_string, rest}, possibilities)

      true ->
        handle_case_by_case(
          rest,
          possibilities,
          instructions,
          string,
          index,
          group,
          type,
          reverse?
        )
    end
  end

  def handle_case_by_case(rest, possibilities, instructions, string, index, group, type, reverse?)

  def handle_case_by_case(
        _rest,
        possibilities,
        instructions,
        string,
        _index,
        [],
        :end_of_group,
        _reverse?
      ) do
    {_, new_string} = String.split_at(string, 1)
    solve_one_line({new_string, instructions}, possibilities)
  end

  def handle_case_by_case(
        _rest,
        possibilities,
        instructions,
        string,
        index,
        group,
        :end_of_group,
        reverse?
      ) do
    # if !reverse? do
    #   solve_one_line({String.reverse(string), Enum.reverse(instructions)}, possibilities,  true)
    # else
    instruction_total = add_instructions(index, instructions)
    to_slice = Enum.count(group)
    new_poss = calculate_using_combination(group, Enum.reverse(instruction_total))

    new_string = String.slice(string, to_slice..String.length(string))
    new_instruction = instructions -- instruction_total
    solve_one_line({new_string, new_instruction}, [new_poss | possibilities])
    # end
  end

  def handle_case_by_case(
        rest,
        possibilities,
        _instructions,
        string,
        _index,
        group,
        :instruction_match,
        _reverse?
      ) do
    to_slice = Enum.count(group)
    new_string = String.slice(string, to_slice..String.length(string))

    {_, new_string_rest} = String.split_at(new_string, 1)
    actul_new_string = "." <> new_string_rest

    solve_one_line({actul_new_string, rest}, possibilities)
  end

  def handle_case_by_case(
        rest,
        possibilities,
        _instructions,
        string,
        _index,
        group,
        :instruction_match_with_replace,
        _reverse?
      ) do
    to_slice = Enum.count(group)
    new_string = String.slice(string, to_slice..String.length(string))

    {_, new_string_rest} = String.split_at(new_string, 1)
    actul_new_string = "." <> new_string_rest

    solve_one_line({actul_new_string, rest}, possibilities)
  end

  def handle_case_by_case(
        _rest,
        possibilities,
        instructions,
        string,
        _index,
        group,
        :reduced_till_the_end,
        reverse?
      ) do
    total = Enum.count(group)
    instruction_total = add_instructions(total, instructions)

    # if Enum.sum(instruction_total) + Enum.count(instruction_total) == Enum.count(group) do
    #   [1 | possibilities]
    # else
    #   new_poss = calculate_using_combination(group, instruction_total)

    #   [new_poss | possibilities]
    # end

    cond do
      Enum.sum(instruction_total) + Enum.count(instruction_total) == Enum.count(group) ->
        possibilities

      # !reverse? ->

      #   solve_one_line({String.reverse(string), Enum.reverse(instructions)}, possibilities, true)

      true ->
        new_poss = calculate_using_combination(group, Enum.reverse(instruction_total))

        [new_poss | possibilities]
    end
  end

  def handle_case_by_case(
        rest,
        possibilities,
        instructions,
        string,
        _index,
        group,
        :instruction_match_with_one_replace,
        reverse?
      ) do
    cond do
      List.first(group) == "?" ->
        # if it start with ? it finishes with # thus replace next by a "."
        to_slice = Enum.count(group)

        new_string = String.slice(string, to_slice..String.length(string))
        {_, new_string_rest} = String.split_at(new_string, 1)
        actul_new_string = "." <> new_string_rest

        solve_one_line({actul_new_string, rest}, possibilities)

      List.last(group) == "?" ->
        # last one is a ? therefore it comes a "." and we don't replace next one
        to_slice = Enum.count(group) - 1

        new_string = String.slice(string, to_slice..String.length(string))
        solve_one_line({new_string, rest}, possibilities)

      true ->
        # if reverse? == true do
        raise "panic"
        # else
        #   solve_one_line({String.reverse(string), Enum.reverse(instructions)}, possibilities, true)
        # end
    end
  end

  def calculate_using_combination(group, instruction_total) do
    number_of_dot = Enum.count(group) - Enum.sum(instruction_total)

    result =
      cond do
        number_of_dot == 0 ->
          1

        Enum.count(group) == Enum.sum(instruction_total) + Enum.count(instruction_total) - 1 ->
          1

        true ->
          list_to_permute =
            (Enum.map(instruction_total, fn count -> String.duplicate("#", count) end) ++
               Enum.map(1..number_of_dot, fn _ -> "." end))
            |> IO.inspect(label: "list to permute")

          IO.inspect(Enum.count(list_to_permute), label: "count")

          # Combination.permutate(list_to_permute, &filter(&1, instruction_total, Enum.join(group)))
          # |> Enum.uniq()
          # |> Enum.count()
      end

    if result == 0 do
      # :tls_server_session_ticket
      raise "boom"
    else
      result
    end
  end

  def add_instructions(total, instructions, instruction_list \\ [])

  def add_instructions(_, [], instruction_list), do: instruction_list

  def add_instructions(total, [instruction | rest], instruction_list) do
    tentative_list = [instruction | instruction_list]
    sum = Enum.sum(tentative_list)
    required_minimum_dot = Enum.count(tentative_list) - 1

    if sum + required_minimum_dot > total do
      instruction_list
    else
      add_instructions(total, rest, [instruction | instruction_list])
    end
  end
end
