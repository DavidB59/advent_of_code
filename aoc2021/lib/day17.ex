defmodule Day17 do
  @x_max 263
  @x_min 207
  @y_min -115
  @y_max -63
  @x_range @x_min..@x_max
  @y_range @y_min..@y_max

  defmacro in_target?(x_pos, y_pos) do
    quote do
      unquote(x_pos) in @x_range and unquote(y_pos) in @y_range
    end
  end

  defmacro cannot_reach_target?(x_pos, y_pos) do
    quote do
      unquote(y_pos) < @y_min or unquote(x_pos) > @x_max
    end
  end

  def solve_part_two() do
    start_x = minimum_start_x_velocity()
    y_velocities = @y_min..-@y_min
    x_velocities = start_x..@x_max

    for(
      x <- x_velocities,
      y <- y_velocities,
      do: if(reached_target?(x, y), do: 1, else: 0)
    )
    |> Enum.sum()
  end

  def reached_target?(x_vel, y_vel, x_pos \\ 0, y_pos \\ 0)
  def reached_target?(_, _, x_pos, y_pos) when in_target?(x_pos, y_pos), do: true
  def reached_target?(_, _, x_pos, y_pos) when cannot_reach_target?(x_pos, y_pos), do: false

  def reached_target?(x_vel, y_vel, x_pos, y_pos) do
    {x_pos, y_pos, x_vel, y_vel} = update_params(x_vel, y_vel, x_pos, y_pos)
    reached_target?(x_vel, y_vel, x_pos, y_pos)
  end

  def solve_part_one() do
    start_x = minimum_start_x_velocity()
    y_velocities = @y_min..-@y_min
    x_velocities = start_x..@x_max

    Enum.reduce(y_velocities, 0, fn y, acc ->
      highest_y =
        Enum.reduce(x_velocities, 0, fn x, acc ->
          highest_y = find_highest_y(x, y)
          return_highest(highest_y, acc)
        end)

      return_highest(highest_y, acc)
    end)
  end

  def find_highest_y(x_vel, y_vel, x_pos \\ 0, y_pos \\ 0, highest_y \\ 0)
  def find_highest_y(_, _, x_pos, y_pos, highest_y) when in_target?(x_pos, y_pos), do: highest_y
  def find_highest_y(_, _, x_pos, y_pos, _) when cannot_reach_target?(x_pos, y_pos), do: 0

  def find_highest_y(x_vel, y_vel, x_pos, y_pos, highest_y) do
    highest_y = return_highest(highest_y, y_pos)

    {x_pos, y_pos, x_vel, y_vel} = update_params(x_vel, y_vel, x_pos, y_pos)
    find_highest_y(x_vel, y_vel, x_pos, y_pos, highest_y)
  end

  def update_params(x_vel, y_vel, x_pos, y_pos) do
    {x_pos + x_vel, y_pos + y_vel, change_x_velocity(x_vel), y_vel - 1}
  end

  def change_x_velocity(x) when x > 0, do: x - 1
  def change_x_velocity(0), do: 0

  def return_highest(a, b) when a > b, do: a
  def return_highest(_, b), do: b

  # sum n + ( n +1 ) -> n * (n-+1) / 2
  # min velocity should be less than twice root square of the min of X
  def minimum_start_x_velocity() do
    @x_min
    |> Kernel.*(2)
    |> :math.sqrt()
    |> floor()
    |> trunc()
  end
end
