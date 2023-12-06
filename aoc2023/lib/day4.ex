defmodule Day4 do
  def file do
    Parser.read_file(4)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Map.new(fn string ->
      "Card " <> rest = string
      [card_number, rest] = String.split(rest, ": ")
      [winning, numbers] = String.split(rest, " | ")

      winning =
        winning
        |> String.split()
        |> Enum.map(&String.to_integer/1)

      numbers =
        numbers
        |> String.split()
        |> Enum.map(&String.to_integer/1)

      {String.to_integer(String.trim(card_number)), {winning, numbers}}
    end)
  end

  def solve_two(input) do
    map_with_counter =
      input
      |> parse()
      |> add_counter()

    map_with_counter
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce(map_with_counter, fn {key, {winning, numbers, _counter}}, acc ->
      nb_winning_cards = number_winning_cards(winning, numbers)

      {_, _, counter} = Map.get(acc, key)

      if nb_winning_cards == 0 do
        acc
      else
        1..nb_winning_cards
        |> Enum.reduce(acc, fn index, map ->
          card = Map.get(map, key + index)

          if card do
            {winning, numbers, card_counter} = Map.get(map, key + index)
            new_counter = card_counter + counter
            Map.put(map, key + index, {winning, numbers, new_counter})
          else
            map
          end
        end)
      end
    end)
    |> Map.values()
    |> Enum.reduce(0, fn {_, _, counter}, acc -> acc + counter end)
  end

  def add_counter(map) do
    Map.new(map, fn {a, b} -> {a, b |> Tuple.append(1)} end)
  end

  def solve(input) do
    input
    |> parse()
    |> Enum.reduce(0, fn {_key, {winning, numbers}}, acc ->
      puissance = number_winning_cards(winning, numbers)

      if puissance == 0 do
        acc
      else
        acc + :math.pow(2, puissance - 1)
      end
    end)
  end

  defp number_winning_cards(winning_numbers, numbers) do
    Enum.reduce(numbers, 0, fn number, acc ->
      if Enum.member?(winning_numbers, number) do
        acc + 1
      else
        acc
      end
    end)
  end
end
