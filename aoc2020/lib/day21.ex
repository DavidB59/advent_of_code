defmodule Day21 do
  @moduledoc """
  Documentation for day21.
  """

  def part_one() do
    file() |> format() |> solve_one
  end

  def part_two() do
    file() |> format() |> solve_two
  end

  def test() do
    Parser.read_file("test_result") |> format() |> solve_two
  end

  def file() do
    Parser.read_file("day21")
  end

  def solve_one(file) do
    allergens_map = match_allergens(file)

    aggregate_ingredients =
      Enum.reduce(file, [], fn {ingredients, _allergens}, acc -> acc ++ ingredients end)

    count_ingredients(aggregate_ingredients, Map.keys(allergens_map))
  end

  def solve_two(file) do
    file
    |> match_allergens()
    |> Enum.map(fn {key, value} -> {key, value} end)
    |> Enum.sort_by(fn {_key, value} -> value end)
    |> Enum.map(fn {key, _value} -> key end)
    |> Enum.join(",")
  end

  def count_ingredients(aggregate_ingredientis, known_allergens, count \\ 0)

  def count_ingredients([last], known_allergens, count) do
    if !Enum.member?(known_allergens, last) do
      count + 1
    else
      count
    end
  end

  def count_ingredients([head | rest], known_allergens, count) do
    new_count =
      if !Enum.member?(known_allergens, head) do
        count + 1
      else
        count
      end

    count_ingredients(rest, known_allergens, new_count)
  end

  def match_allergens(file, map_found \\ %{}, found_allergens \\ [])

  def match_allergens(file, map_found, found_allergens) do
    singles =
      file
      |> Enum.map(fn {ingredient, allergens} -> {ingredient, allergens -- found_allergens} end)
      |> Enum.map(fn {_ingredients, allergens} -> allergens end)
      |> List.flatten()
      |> Enum.sort()
      |> Enum.dedup()
      |> IO.inspect()

    if singles == [] do
      map_found
    else
      map_found = eliminate(singles, file, map_found)
      found_allergens = Map.values(map_found) |> IO.inspect(label: "found_allergens")

      match_allergens(file, map_found, found_allergens)
    end
  end

  def eliminate(list_single_allergens, file, map \\ %{})

  def eliminate([allergen], file, map) do
    IO.inspect(allergen, label: "allergen")
    find_match_ingredient_allergen(allergen, file, map)
  end

  def eliminate([head | rest], file, map) do
    IO.inspect(head, label: "head")
    map_found = find_match_ingredient_allergen(head, file, map)

    eliminate(rest, file, map_found)
  end

  def find_match_ingredient_allergen(allergen, file, map) do
    all_rep_contains_head =
      Enum.filter(file, fn {_ingredients, allergens} ->
        Enum.member?(allergens, allergen)
      end)

    {ingredient_list, _} =
      Enum.min_by(all_rep_contains_head, fn {ingredients, _allergens} -> length(ingredients) end)

    already_matched = Map.keys(map)

    found_allergens =
      (Enum.filter(ingredient_list, fn ingredient ->
         Enum.all?(all_rep_contains_head, fn {ing, _all} ->
           Enum.member?(ing, ingredient)
         end)
       end) -- already_matched)
      |> IO.inspect(label: "found")

    map_found =
      case found_allergens do
        [found_all] -> Map.put(map, found_all, allergen)
        _ -> map
      end

    map_found
  end

  def format(file) do
    file
    |> Enum.map(fn string ->
      [ingredients, allergens] = string |> String.split(" (contains")

      allergens =
        allergens
        |> String.trim(")")
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.trim/1)

      ingredients =
        ingredients
        |> String.trim()
        |> String.split(" ")

      {ingredients, allergens}
    end)
  end
end
