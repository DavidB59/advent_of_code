defmodule Day25 do
  @moduledoc """
  Documentation for Day25.
  """

  def part_one() do
    {card_public_key, door_public_key} = input()
    card_loop_size = loop(card_public_key)
    door_loop_size = loop(door_public_key)

    encryption_key = secret_key(1, card_public_key, door_loop_size)
    enc_cryp_2 = secret_key(1, door_public_key, card_loop_size)
    if enc_cryp_2 == encryption_key, do: encryption_key
  end

  def input() do
    {8_421_034, 15_993_936}
  end

  def test do
    {5_764_801, 17_807_724}
    loop(1, 5_764_801)
  end

  def secret_key(secret_key, public_key, loop, time \\ 0)
  def secret_key(secret_key, _public_key, loop, loop), do: secret_key

  def secret_key(secret_key, public_key, loop, time) do
    next_value = (secret_key * public_key) |> Integer.mod(20_201_227)
    secret_key(next_value, public_key, loop, time + 1)
  end

  def loop(key, current_value \\ 1, times \\ 0)

  def loop(key, key, times), do: times

  def loop(key, current_value, times) do
    next_value = (7 * current_value) |> Integer.mod(20_201_227)
    loop(key, next_value, times + 1)
  end
end
