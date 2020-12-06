defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

  def part_one() do
    file = file()
    Enum.count(file, &valid?(&1))
  end

  def part_two() do
    file = file()
    Enum.count(file, &valid_fields?(&1))
  end

  def valid?(%{
        byr: _byr,
        iyr: _iyr,
        eyr: _eyr,
        hgt: _hgt,
        hcl: _hcl,
        ecl: _ecl,
        pid: _pid
      }),
      do: true

  def valid?(_), do: false

  def valid_fields?(%{
        byr: byr,
        iyr: iyr,
        eyr: eyr,
        hgt: hgt,
        hcl: hcl,
        ecl: ecl,
        pid: pid
      }) do
    valid_number(byr, 1920..2002) &&
      valid_number(iyr, 2010..2020) &&
      valid_number(eyr, 2020..2030) &&
      hgt_valid(hgt) &&
      hcl_valid(hcl) &&
      ecl_valid(ecl) &&
      pid_valid(pid)
  end

  def valid_fields?(_), do: false

  def pid_valid(pid) do
    String.length(pid) === 9 && check_integer(pid)
  end

  def check_integer(string) do
    {_a, b} = Integer.parse(string)
    b === ""
  end

  def hcl_valid(hcl) do
    if String.starts_with?(hcl, "#") do
      hcl = String.trim(hcl, "#")
      Regex.match?(~r/^[0-9a-f]{6}$/, hcl)
    else
      false
    end
  end

  def ecl_valid(ecl) do
    valid_ecl = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    Enum.member?(valid_ecl, ecl)
  end

  def hgt_valid(hgt) do
    cond do
      String.ends_with?(hgt, "cm") ->
        hgt |> String.trim("cm") |> valid_number(150..193)

      String.ends_with?(hgt, "in") ->
        hgt |> String.trim("in") |> valid_number(59..76)

      true ->
        false
    end
  end

  def valid_number(string, interval) do
    Enum.member?(interval, String.to_integer(string))
  end

  def test do
    %{
      byr: "1980",
      iyr: "2012",
      eyr: "2030",
      hgt: "74in",
      hcl: "#623a2f",
      ecl: "grn",
      pid: "087499704"
    }
  end

  def file do
    Parser.read_file("day4") |> formatted()
  end

  def formatted(file) do
    {list, _index} = group(file)
    to_map(list)
  end

  def group(list) do
    Enum.reduce(list, {[], 0}, fn
      x, {list, index} ->
        if x === "" do
          {list, index + 1}
        else
          if Enum.at(list, index) do
            {List.replace_at(list, index, Enum.at(list, index) <> " " <> x), index}
          else
            {list ++ [x], index}
          end
        end
    end)
  end

  def to_map(list) do
    Enum.map(list, fn string ->
      string
      |> String.split(" ")
      |> Enum.reduce(%{}, fn string, acc ->
        [key, value] = String.split(string, ":")

        Map.put(acc, String.to_atom(key), value)
      end)
    end)
  end
end
