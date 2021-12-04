defmodule Day4 do
  def file do
    Parser.read_file("day4")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    {[[number_list]], boards} =
      input
      |> Enum.chunk_by(&(&1 == ""))
      |> Enum.reject(&(&1 == [""]))
      |> Enum.split(1)

    boards_with_coordinates = Enum.map(boards, &to_graph/1)

    number_list =
      number_list
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {number_list, boards_with_coordinates}
  end

  def to_graph(board) do
    board
    |> Enum.map(fn row ->
      row
      |> String.split(" ")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)
    end)
    |> Utils.list_list_to_graph()
    |> Utils.exchange_key_value()
  end

  def solve_part_one do
    {winner, last_number} =
      file()
      |> parse()
      |> winner_board_and_number()

    winner
    |> get_unmarked_numbers()
    |> Enum.sum()
    |> Kernel.*(last_number)
  end

  def get_unmarked_numbers(board) do
    board
    |> Enum.reject(fn {k, _} -> is_tuple(k) end)
    |> Enum.map(fn {k, _} -> k end)
  end

  def winner_board_and_number({numbers, boards}) do
    Enum.reduce_while(numbers, boards, fn number, boards ->
      new_boards = Enum.map(boards, &mark_number(&1, number))
      winner = Enum.find(new_boards, &won?/1)

      if winner do
        {:halt, {winner, number}}
      else
        {:cont, new_boards}
      end
    end)
  end

  def mark_number(board, number) do
    case Map.get(board, number) do
      nil ->
        board

      found ->
        board
        |> Map.drop([number])
        |> Map.put({number, :found}, found)
    end
  end

  def won?(board) do
    row_winner =
      board
      |> Enum.group_by(fn {_number, {x, _y}} -> x end, fn {number, {_x, _y}} -> number end)
      |> Enum.find(fn {_k, v} -> Enum.all?(v, &is_tuple/1) end)

    column_winner =
      board
      |> Enum.group_by(fn {_number, {_x, y}} -> y end, fn {number, {_x, _y}} -> number end)
      |> Enum.find(fn {_k, v} -> Enum.all?(v, &is_tuple/1) end)

    if row_winner || column_winner, do: true, else: false
  end

  def solve_part_two() do
    {winner, last_number} =
      file()
      |> parse()
      |> last_winner_board_and_number()

    winner
    |> get_unmarked_numbers()
    |> Enum.sum()
    |> Kernel.*(last_number)
  end

  def last_winner_board_and_number({numbers, boards}) do
    Enum.reduce_while(numbers, boards, fn
      number, [last_board] ->
        new_board = mark_number(last_board, number)

        if won?(new_board) do
          {:halt, {new_board, number}}
        else
          {:cont, [new_board]}
        end

      number, boards ->
        result =
          boards
          |> Enum.map(&mark_number(&1, number))
          |> remove_all_winners()

        {:cont, result}
    end)
  end

  def remove_all_winners(boards) do
    winner = Enum.find(boards, &won?/1)

    case winner do
      nil ->
        boards

      winner ->
        boards
        |> List.delete(winner)
        |> remove_all_winners()
    end
  end
end
