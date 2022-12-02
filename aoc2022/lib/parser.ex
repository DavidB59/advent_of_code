defmodule Parser do
  def read_file(day) do
    path = __DIR__ <> "/input/#{day}"

    case File.read(path) do
      {:ok, file} -> file |> String.split("\n")
      error -> error
    end
  end
end
