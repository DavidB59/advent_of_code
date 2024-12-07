defmodule Day20 do
  def file do
    Parser.read_file(20)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.reduce(%{}, fn string, acc ->
      [a, b] = String.split(string, " -> ")

      {key, state} = key_and_state(a)
      Map.put(acc, key, %{value: String.split(b, ", "), state: state})
    end)
    |> update_state_for_conjonction_module()
  end

  def update_state_for_conjonction_module(map) do
    Enum.reduce(map, %{}, fn
      {key, %{state: :low} = value}, acc ->
        input_module =
          Enum.filter(map, fn {_, %{value: values}} -> Enum.member?(values, key) end)
          |> Enum.map(&elem(&1, 0))
          |> Map.new(fn a -> {a, :low} end)

        new_value = Map.put(value, :state, input_module)
        Map.put(acc, key, new_value)

      {key, value}, acc ->
        Map.put(acc, key, value)
    end)
  end

  def key_and_state("broadcaster"), do: {"broadcaster", nil}

  def key_and_state(string) do
    {type, key} = String.split_at(string, 1)
    {key, state(type)}
  end

  def state("%"), do: :off
  def state("&"), do: :low

  def solve(input \\ file()) do
    map = parse(input)

    {high, low} = press_button_multiple_times(map, {0, 0}, 0)
    high * low
  end

  def press_button_multiple_times(_map, pulses_nb, 1000), do: pulses_nb

  def press_button_multiple_times(map, pulses_nb, count) do
    {new_map, {high, low}} = press_button(map, pulses_nb, count)
    press_button_multiple_times(new_map, {high, low + 1}, count + 1)
  end

  def press_button(
        map,
        {high_nb, low_nb} = pulses_nb,
        count,
        sent_pulse \\ [{"broadcaster", :low, nil}]
      ) do
    {new_map, pulse_to_send} =
      Enum.reduce(sent_pulse, {map, []}, fn {target, pulse_type, sender},
                                            {map, new_pulse} = acc ->
        resp = Map.get(map, target)

        if resp do
          {list_new_pulse, new_map} =
            determine_pulse_effect(resp, map, target, pulse_type, sender)

          {new_map, new_pulse ++ list_new_pulse}
        else
          # case of output
          acc
        end
      end)

    high_nb =
      (pulse_to_send |> Enum.filter(fn {_, type, _} -> type == :high end) |> Enum.count()) +
        high_nb

    low_nb =
      (pulse_to_send |> Enum.filter(fn {_, type, _} -> type == :low end) |> Enum.count()) + low_nb

    if pulse_to_send == [] do
      {map, pulses_nb}
    else
      press_button(new_map, {high_nb, low_nb}, count, pulse_to_send)
    end
  end

  def solve_two(input \\ file()) do
    input
    |> parse
    |> find_periods()
    |> Map.values()
    |> Enum.reduce(&RC.lcm/2)
  end

  def find_periods(map, count \\ 1, period_map \\ %{}) do
    {new_map, period_map} = press_button_periods(map, count, period_map)

    if count == 5000 do
      period_map
    else
      find_periods(new_map, count + 1, period_map)
    end
  end

  def press_button_periods(
        map,
        count,
        period_map,
        sent_pulse \\ [{"broadcaster", :low, nil}]
      ) do
    {new_map, pulse_to_send} =
      Enum.reduce(sent_pulse, {map, []}, fn {target, pulse_type, sender},
                                            {map, new_pulse} = acc ->
        resp = Map.get(map, target)

        if resp do
          {list_new_pulse, new_map} =
            determine_pulse_effect(resp, map, target, pulse_type, sender)

          {new_map, new_pulse ++ list_new_pulse}
        else
          # case of output
          acc
        end
      end)

    filtered =
      pulse_to_send
      |> Enum.filter(fn {target, type, _origin} -> target == "lb" and type == :high end)

    # ["br", "fk", "lf", "rz"]

    period_map =
      case filtered do
        [] ->
          period_map

        [{"lb", :high, origin}] ->
          Map.put(period_map, origin, count)
      end

    if pulse_to_send == [] do
      {map, period_map}
    else
      press_button_periods(new_map, count, period_map, pulse_to_send)
    end
  end

  #
  # broadcaster send low pulse to everyone
  def determine_pulse_effect(%{state: nil, value: value}, map, key, _pulse_type, _) do
    {Enum.map(value, fn value -> {value, :low, key} end), map}
  end

  # fllip flop receive high pulse ignore
  def determine_pulse_effect(%{state: state, value: _value}, map, _key, :high, _)
      when state in [:off, :on] do
    {[], map}
  end

  # fllip flop receive low pulse
  # when it's off, turn on and send high pulse
  def determine_pulse_effect(%{state: :off, value: value}, map, key, :low, _) do
    new_map = Map.update!(map, key, &Map.put(&1, :state, :on))
    {Enum.map(value, fn value -> {value, :high, key} end), new_map}
  end

  # when it's on, turn off and send low pulse
  def determine_pulse_effect(%{state: :on, value: value}, map, key, :low, _) do
    new_map = Map.update!(map, key, &Map.put(&1, :state, :off))
    {Enum.map(value, fn value -> {value, :low, key} end), new_map}
  end

  def determine_pulse_effect(%{state: state_map, value: value}, map, key, pulse_type, sender)
      when is_map(state_map) do
    new_state_map = Map.update!(state_map, sender, fn _ -> pulse_type end)

    pulse_type_to_send =
      if new_state_map |> Map.values() |> Enum.all?(&(&1 == :high)) do
        :low
      else
        :high
      end

    new_map = Map.update!(map, key, &Map.put(&1, :state, new_state_map))
    {Enum.map(value, fn value -> {value, pulse_type_to_send, key} end), new_map}
  end
end
