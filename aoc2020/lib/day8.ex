defmodule Day8 do
  @moduledoc """
  Documentation for Day8.
  """

  def part_one do
    start = init()
    run_command(start)
  end

  def part_two do
    start = init()
    fix_code(start)
  end

  def fix_code(start) do
    case run_command(start) do
      {:loop, _} ->
        %{changed_pos: pos} = start
        file = file() |> format()
        {new_list, new_pos} = change(file, pos)

        new_start = %{start | list: new_list, changed_pos: new_pos}

        fix_code(new_start)

      {:end_of_line, acc} ->
        acc
    end
  end

  def change(list, position \\ 0) do
    {keep, to_change} = Enum.split(list, position)

    chge_index =
      Enum.find_index(to_change, fn {command, _arg} ->
        String.starts_with?(command, "nop") || String.starts_with?(command, "jmp")
      end)

    new_value = to_change |> Enum.at(chge_index) |> change_instruction()

    changed = List.replace_at(to_change, chge_index, new_value)
    new_pos = length(keep) + chge_index + 1
    {keep ++ changed, new_pos}
  end

  def change_instruction({"nop", arg}), do: {"jmp", arg}
  def change_instruction({"jmp", arg}), do: {"nop", arg}

  def run_command(commands) do
    case stop(commands) do
      :keep_going ->
        %{index: index, list: list} = commands
        new_command = command(Enum.at(list, index), commands)
        run_command(new_command)

      {:loop, accumulator} ->
        {:loop, accumulator}

      {:end_of_line, accumulator} ->
        {:end_of_line, accumulator}
    end
  end

  def init do
    file = file() |> format()

    %{
      index: 0,
      accumulator: 0,
      list: file,
      old_command: [],
      changed_pos: 0
    }
  end

  def stop(%{old_command: old_command, accumulator: accumulator, index: index, list: list}) do
    cond do
      Enum.member?(old_command, index) -> {:loop, accumulator}
      index >= length(list) -> {:end_of_line, accumulator}
      true -> :keep_going
    end
  end

  def command(
        {"acc", arg},
        %{
          index: index,
          accumulator: accumulator,
          old_command: old_command
        } = commands
      ) do
    old_command = old_command ++ [index]
    accumulator = accumulator + arg
    index = index + 1
    %{commands | index: index, accumulator: accumulator, old_command: old_command}
  end

  def command({"jmp", arg}, %{index: index, old_command: old_command} = commands) do
    old_command = old_command ++ [index]

    index = index + arg

    %{commands | index: index, old_command: old_command}
  end

  def command({"nop", _arg}, %{index: index, old_command: old_command} = commands) do
    old_command = old_command ++ [index]

    index = index + 1

    %{commands | index: index, old_command: old_command}
  end

  def file do
    Parser.read_file("day8")
  end

  def test do
    Parser.read_file("test")
  end

  def format(file) do
    file
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  end
end
