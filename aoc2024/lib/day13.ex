defmodule Day13 do
  require Integer

  def file do
    Parser.read_file(13)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.chunk_every(4)
    |> Enum.map(fn list ->
      [[x_a, y_a], [x_b, y_b], [x_target, y_target]] =
        list
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(fn string ->
          string
          |> String.split(",")
          |> Enum.map(&(&1 |> Utils.extract_number_from_string() |> String.to_integer()))
        end)

      %{
        button_a: %{x: x_a, y: y_a},
        button_b: %{x: x_b, y: y_b},
        target: %{x: x_target, y: y_target}
      }
    end)
  end

  def solve(input \\ file()) do
    input
    |> parse
    |> Enum.map(&solve_equation_deux_inconnues/1)
    |> Enum.filter(& &1)
    |> Enum.map(fn {a, b} -> a * 3 + b end)
    |> Enum.sum()
    |> trunc()
  end

  def solve_two(input \\ file()) do
    input
    |> parse
    |> Enum.map(&add_10000000000000/1)
    |> Enum.map(&solve_equation_deux_inconnues/1)
    |> Enum.filter(& &1)
    |> Enum.map(fn {a, b} -> a * 3 + b end)
    |> Enum.sum()
    |> trunc()
  end

  def add_10000000000000(%{
        button_a: %{x: x_a, y: y_a},
        button_b: %{x: x_b, y: y_b},
        target: %{x: x_target, y: y_target}
      }) do
    %{
      button_a: %{x: x_a, y: y_a},
      button_b: %{x: x_b, y: y_b},
      target: %{x: x_target + 10_000_000_000_000, y: y_target + 10_000_000_000_000}
    }
  end

  def solve_equation_deux_inconnues(%{
        button_a: %{x: x_a, y: y_a},
        button_b: %{x: x_b, y: y_b},
        target: %{x: x_target, y: y_target}
      }) do
    # eq1 = "#{x_a} * a + #{x_b} * b = #{x_target}" |> IO.inspect()
    # eq2 = "#{y_a} * a + #{y_b} * b = #{y_target}" |> IO.inspect()

    # Pivot de Gauss pour equation a deux inconnus.
    # multiplie ligne 1 par coef 2eme inconnue ligne 2
    # multiplie ligne 2 par coef 2eme inconnue ligne 1
    # soustrait les deux lignes pour faire disparaitre la deuxieme inconnue
    dessus = x_target * y_b - y_target * x_b
    dessous = x_a * y_b - y_a * x_b
    a = dessus / dessous
    b = (x_target - x_a * a) / x_b

    # trunc pour verifier que les reponses sont des entiers
    if trunc(a) == a and trunc(b) == b do
      {a, b}
    else
      false
    end
  end

  # dumb solution finding
  def find_solution(%{
        button_a: %{x: x_a, y: y_a},
        button_b: %{x: x_b, y: y_b},
        target: %{x: x_target, y: y_target}
      }) do
    0..100
    |> Enum.map(fn i ->
      result_ax = i * x_a
      result_ay = i * y_a

      j =
        0..100
        |> Enum.find(fn j ->
          result_bx = j * x_b
          result_by = j * y_b
          bool1 = result_ax + result_bx == x_target
          bool2 = result_ay + result_by == y_target
          bool1 and bool2
        end)

      if is_nil(j) do
        false
      else
        {i, j}
      end
    end)
    |> Enum.filter(& &1)
  end
end
