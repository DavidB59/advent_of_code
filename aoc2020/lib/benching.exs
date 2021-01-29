defmodule Benching do
  @moduledoc """
  Documentation for day24.
  """
  alias Day23

  Benchee.run(%{
    "test" => fn -> Day23.test(100) end
  })

  # def test do
  #   Day23.test(100)
  # end
end
