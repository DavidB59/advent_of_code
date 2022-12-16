defmodule Parser do
  def read_file(day) when is_integer(day) do
    day
    |> AdventOfCode.Input.get!(2018)
    |> String.split("\n")
    |> Enum.drop(-1)
  end

  def read_file(day) do
    path = __DIR__ <> "/input/#{day}"

    case File.read(path) do
      {:ok, file} -> file |> String.split("\n")
      error -> error
    end
  end
end
