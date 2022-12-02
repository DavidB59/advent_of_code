defmodule Day2 do
  # A = Rock =  1
  # B = Paper = 2
  # C = scissor  = 3
  # win = 6 drwa = 3 defeat = 0
  # X Y Z = rock paper scissor
  def file do
    "day2" |> Parser.read_file()
  end

  def test do
    "test" |> Parser.read_file()
  end

  def format(file) do
    file
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn [a, _, c] -> {a, c} end)
  end

  def part_one(file) do
    file
    |> Enum.map(&calculate_score/1)
    |> Enum.sum()
  end

  def part_two(file) do
    file
    |> Enum.map(&calculate_score_2/1)
    |> Enum.sum()
  end

  def calculate_score({"A", "X"}), do: 1 + 3
  def calculate_score({"A", "Y"}), do: 2 + 6
  def calculate_score({"A", "Z"}), do: 3 + 0
  def calculate_score({"B", "X"}), do: 1 + 0
  def calculate_score({"B", "Y"}), do: 2 + 3
  def calculate_score({"B", "Z"}), do: 3 + 6
  def calculate_score({"C", "X"}), do: 1 + 6
  def calculate_score({"C", "Y"}), do: 2 + 0
  def calculate_score({"C", "Z"}), do: 3 + 3

  def calculate_score_2({"A", "X"}), do: 0 + 3
  def calculate_score_2({"A", "Y"}), do: 3 + 1
  def calculate_score_2({"A", "Z"}), do: 6 + 2
  def calculate_score_2({"B", "X"}), do: 0 + 1
  def calculate_score_2({"B", "Y"}), do: 3 + 2
  def calculate_score_2({"B", "Z"}), do: 6 + 3
  def calculate_score_2({"C", "X"}), do: 0 + 2
  def calculate_score_2({"C", "Y"}), do: 3 + 3
  def calculate_score_2({"C", "Z"}), do: 6 + 1
end
