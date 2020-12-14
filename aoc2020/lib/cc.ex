defmodule CC do
  def format do
    file()
    |> Enum.filter(&String.contains?(&1, "deployed"))
    |> Enum.map(fn string ->
      string |> String.split("deployed") |> trim_both()
    end)
    |> Enum.group_by(fn {a, _b} -> a end, fn {_a, b} -> b end)
    |> Enum.map(fn {a, b} -> {a, Enum.sum(b)} end)
  end

  def file do
    Parser.read_file("log")
  end

  def trim_both([a, b]) do
    {a |> String.trim(), b |> String.trim() |> Integer.parse() |> elem(0)}
  end

  def do_10k(attack, defense) do
    times = 3_000_0

    attack_win =
      Enum.map(1..times, fn _n -> stats({attack, defense}) end)
      |> Enum.count(fn {_a, b} -> b == "attack wins" end)

    attack_win / times * 100
  end

  def stats({attack, 0}), do: {attack, "attack wins"}
  def stats({0, defense}), do: {defense, "defense wins"}

  def stats({attack, defense}) do
    nb_attack_dice = if attack > 2, do: 3, else: attack
    nb_defense_dice = if defense > 1, do: 2, else: defense

    attack_dice =
      Enum.map(1..nb_attack_dice, fn _x -> :rand.uniform(6) end) |> Enum.sort() |> Enum.reverse()

    defense_dice =
      Enum.map(1..nb_defense_dice, fn _x -> :rand.uniform(6) end) |> Enum.sort() |> Enum.reverse()

    calc_win(attack_dice, defense_dice, attack, defense) |> stats()
  end

  def calc_win(_, [], attack, defense), do: {attack, defense}
  def calc_win([], _, attack, defense), do: {attack, defense}

  def calc_win([h_attack | t_attack], [h_defense | t_defense], attack, defense) do
    if h_attack > h_defense do
      calc_win(t_attack, t_defense, attack, defense - 1)
    else
      calc_win(t_attack, t_defense, attack - 1, defense)
    end
  end
end
