defmodule Day19 do
  @moduledoc """
  Documentation for Day19.
  """
  @length 8
  def part_one() do
    file() |> format() |> solve_one()
  end

  def part_two() do
    file() |> format() |> solve_two()
  end

  def test() do
    # |> solve_one
    Parser.read_file("test") |> format() |> solve_two()
  end

  def solve_one({map, messages}) do
    string = Map.get(map, "0")
    rules = reducer_two(string, map)
    Enum.filter(messages, fn message -> Enum.member?(rules, message) end) |> Enum.count()
  end

  def solve_two({map, messages}) do
    rule_8 = get_set_rules(map, "8") |> IO.inspect(label: "rule 8")
    rule_31 = get_set_rules(map, "31") |> IO.inspect(label: "rule 31")

    messages
    |> Enum.filter(fn message -> match(message, rule_8, rule_31) end)
    |> Enum.filter(fn message -> match_minimum_requirement(message, rule_8, rule_31) end)
    |> Enum.count()
  end

  def get_set_rules(map, key) do
    string = Map.get(map, key)

    if String.contains?(string, "|") do
      [one, two] = String.split(string, "|")
      alpha = one |> String.trim() |> reducer_two(map)
      beta = two |> String.trim() |> reducer_two(map)
      alpha ++ beta
    else
      reducer_two(string, map)
    end
  end

  def reducer_two(string, map) do
    list = string |> String.split(" ")

    Enum.reduce(list, [""], fn elt, acc ->
      content = Map.get(map, elt)
      ab = is_a_b(content)

      cond do
        !is_nil(ab) ->
          Enum.map(acc, fn string -> [string <> ab] end) |> List.flatten()

        String.contains?(content, "|") ->
          [one, two] = String.split(content, "|")
          alpha = one |> String.trim() |> reducer_two(map)
          beta = two |> String.trim() |> reducer_two(map)

          Enum.map(acc, fn string ->
            Enum.map(alpha, fn alpha_string -> string <> alpha_string end) ++
              Enum.map(beta, fn alpha_string -> string <> alpha_string end)
          end)
          |> List.flatten()

        true ->
          result = reducer_two(content, map)

          Enum.map(acc, fn string ->
            Enum.map(result, fn alpha_string -> string <> alpha_string end)
          end)
          |> List.flatten()
      end
    end)
  end

  def is_a_b(string) do
    case Regex.run(~r/[a-b]/, string) do
      nil -> nil
      [resp] -> resp
    end
  end

  def file() do
    Parser.read_file("day19")
  end

  def format(file) do
    {rules, [_head | messages]} = file |> Enum.split_while(&(&1 != ""))
    {format_rules(rules), messages}
  end

  def format_rules(rules) do
    rules
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [a, b] ->
      b = String.trim(b)
      {a, b}
    end)
    |> Map.new()
  end

  def member_rule_8(string_8, rule_8), do: Enum.member?(rule_8, string_8)

  def match_rule_31(string, rule_31, number8, number31 \\ 0) do
    if String.length(string) == @length do
      member_rule_31(string, rule_31) and number8 > number31 + 1
    else
      {string_31, rest} = String.split_at(string, @length)

      if member_rule_31(string_31, rule_31) do
        match_rule_31(rest, rule_31, number8, number31 + 1)
      else
        false
      end
    end
  end

  def member_rule_31(string_31, rule_31), do: Enum.member?(rule_31, string_31)

  def match(string, rule_8, rule_31, number8 \\ 0) do
    if String.length(string) == @length do
      member_rule_31(string, rule_31)
    else
      {string_5, rest} = String.split_at(string, @length)

      if member_rule_8(string_5, rule_8) do
        match(rest, rule_8, rule_31, number8 + 1)
      else
        match_rule_31(string, rule_31, number8)
      end
    end
  end

  # def match_minimum_requirement(string, rule_8, rule_31) do
  #   {string_1, rest} = String.split_at(string, @length)
  #   {string_2, _rest} = String.split_at(rest, @length)

  #   string_31 =
  #     string |> String.reverse() |> String.split_at(@length) |> elem(0) |> String.reverse()

  #   member_rule_8(string_1, rule_8) and member_rule_8(string_2, rule_8) and
  #     member_rule_31(string_31, rule_31)
  # end

  def match_minimum_requirement(_, _, _), do: true
end
