defmodule A do
  @east {1, 0}
  @south {0, -1}
  @west {-1, 0}
  @north {0, 1}

  # CCW
  # 10, 1  ->  -1, 10  ->  -10, -1  ->  1, -10
  
  # CW
  # 10, 1  ->  1, -10  ->  -10, -1  ->  -1, 10

  defstruct [
    x: 0,
    y: 0,
    wx: 10,
    wy: 1
  ]

  def parse do
    File.stream!("input.txt")
    |> Enum.map(fn << inst, arg::binary >> ->
      {inst, arg |> String.trim |> String.to_integer}
    end)
  end

  def step({?N, arg}, ship), do: %A{ship|wy: ship.wy+arg}
  def step({?S, arg}, ship), do: %A{ship|wy: ship.wy-arg}
  def step({?E, arg}, ship), do: %A{ship|wx: ship.wx+arg}
  def step({?W, arg}, ship), do: %A{ship|wx: ship.wx-arg}
  def step({?R, 0}, ship), do: ship
  def step({?R, arg}, ship) do
    step(
      {?R, arg - 90},
      %A{ ship | wx: ship.wy, wy: -ship.wx }
    )
  end
  def step({?L, 0}, ship), do: ship
  def step({?L, arg}, ship) do
    step(
      {?L, arg - 90},
      %A{ ship | wx: -ship.wy, wy: ship.wx }
    )
  end
  def step({?F, arg}, ship) do
    %A{ ship | x: ship.x + ship.wx * arg, y: ship.y + ship.wy * arg }
  end

  def solve12b do
    parse()
    |> Enum.reduce(%A{}, &step/2)
    |> (fn %A{x: x, y: y} -> abs(x) + abs(y) end).()
    # 1503 is too low
  end
end
