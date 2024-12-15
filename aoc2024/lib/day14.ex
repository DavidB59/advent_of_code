defmodule Day14 do
  require Integer

  @x_max 101 - 1
  @y_max 103 - 1
  @cycle 10403

  # @x_max 11 - 1
  # @y_max 7 - 1
  def file do
    Parser.read_file(14)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      [pos, vitesse] = String.split(string, " ")

      [x, y] =
        pos
        |> String.split(",")
        |> Enum.map(fn a -> a |> Utils.extract_number_from_string() |> String.to_integer() end)

      [vx, vy] =
        vitesse
        |> String.split(",")
        |> Enum.map(fn a -> a |> String.trim("v=") |> Code.eval_string() |> elem(0) end)

      {{x, y}, {vx, vy}}
    end)
  end

  def solve(input \\ file(), target \\ @cycle) do
    input
    |> parse
    |> do_100_seconds(target, %{})

  end

  def do_100_seconds(list, target, cycle_check, counter \\ 0) do


    # if counter == target do\
    if do_I_have_a_line(list) do
      IO.inspect(counter)
      list
    else

      list
      |> Enum.map(&move_robot/1)
      |> do_100_seconds(target, cycle_check, counter + 1)
    end
  end

  def make_3d(map) do
    map
    |> Enum.map(fn {counter, vitess_pos_list} ->
      vitess_pos_list
      |> Enum.map(fn {{x, y}, _vitess} ->
        {x, y, 5 * counter}
      end)
    end)
    |> List.flatten()
  end

  def do_I_have_a_line(list) do
    list
    |> get_only_positions
    # |> Enum.sort_by(fn {x, y} -> x end)
    |> Enum.group_by(fn {_x, y} -> y end, fn {x, _y} -> x end)
    |> Enum.map(fn {_x, y} -> Enum.sort(y) end)
    |> Enum.any?(fn list -> is_it_a_line(list) end)
  end

  def is_it_a_line(list) do
    if length(list) > 10 do
      # IO.inspect(list, label: "list")
      # IO.inspect(Enum.at(list, 4) )
      Enum.at(list, 4) == Enum.at(list, 5) - 1 and
        Enum.at(list, 4) == Enum.at(list, 6) - 2 and
        Enum.at(list, 4) == Enum.at(list, 7) - 3 and
        Enum.at(list, 4) == Enum.at(list, 8) - 4 and
        Enum.at(list, 4) == Enum.at(list, 9) - 5 and
        Enum.at(list, 4) == Enum.at(list, 10) - 6
    else
      false
    end
  end

  def get_only_positions(list) do
    Enum.map(list, &elem(&1, 0))
  end

  # def make_lot_2d(map) do
  #   map
  #   |> Enum.map(fn {counter, vitess_pos_list} ->
  #     vitess_pos_list
  #     |> Enum.map(fn {{x, y}, _vitess} ->
  #       {x, y}
  #     end)
  #   end)
  #   # |> List.flatten()
  # end

  def plot_lost(list) do
    Gnuplot.plot([[:plot, "-", :title, "counter ", :with, :dot]], [list])
  end

  def plot(list, counter) when counter > 200 do
    l1 = Enum.map(list, &elem(&1, 0))
    # l1 |> List.last() |> IO.inspect()
    Gnuplot.plot([[:plot, "-", :title, "counter #{counter}", :with, :points]], [l1])
  end

  def plot(_list, _counter), do: :ok

  # def plot(list, counter) do

  #   l1 = Enum.map(list, &elem(&1, 0))
  #   Gnuplot.plot([[:plot, "-", :title, "counter #{counter}", :with, :circle]], [l1])

  # end

  def split_in_quadrant(list) do
    q1 =
      list
      |> Enum.map(&elem(&1, 0))
      |> Enum.filter(fn {x, y} -> x < @x_max / 2 and y < @y_max / 2 end)
      # |> IO.inspect(label: "q1")
      |> Enum.count()

    q2 =
      list
      |> Enum.map(&elem(&1, 0))
      |> Enum.filter(fn {x, y} -> x < @x_max / 2 and y > @y_max / 2 end)
      # |> IO.inspect(label: "q2")
      |> Enum.count()

    q3 =
      list
      |> Enum.map(&elem(&1, 0))
      |> Enum.filter(fn {x, y} -> x > @x_max / 2 and y > @y_max / 2 end)
      # |> IO.inspect(label: "q3")
      |> Enum.count()

    q4 =
      list
      |> Enum.map(&elem(&1, 0))
      |> Enum.filter(fn {x, y} -> x > @x_max / 2 and y < @y_max / 2 end)
      # |> IO.inspect(label: "q4")
      |> Enum.count()

    q1 * q2 * q3 * q4
  end

  ## can probably be calculated to be done in one go for 100 sec
  ## prob part 2
  def move_robot({{x, y}, {vx, vy}}) do
    new_x = x + vx
    new_x = if new_x > @x_max, do: new_x - @x_max - 1, else: new_x
    new_x = if new_x < 0, do: new_x + @x_max + 1, else: new_x

    new_y = y + vy
    new_y = if new_y > @y_max, do: new_y - @y_max - 1, else: new_y
    new_y = if new_y < 0, do: new_y + @y_max + 1, else: new_y

    {{new_x, new_y}, {vx, vy}}
  end
end
