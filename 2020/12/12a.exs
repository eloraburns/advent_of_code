defmodule A do
  @east {1, 0}
  @south {0, -1}
  @west {-1, 0}
  @north {0, 1}
  @directions [@east, @south, @west, @north]
  @ndirs length(@directions)

  defstruct [
    x: 0,
    y: 0,
    dir: 0
  ]

  def parse do
    File.stream!("input.txt")
    |> Enum.map(fn << inst, arg::binary >> ->
      {inst, arg |> String.trim |> String.to_integer}
    end)
  end

  def step({?N, arg}, ship), do: %A{ship|y: ship.y+arg}
  def step({?S, arg}, ship), do: %A{ship|y: ship.y-arg}
  def step({?E, arg}, ship), do: %A{ship|x: ship.x+arg}
  def step({?W, arg}, ship), do: %A{ship|x: ship.x-arg}
  def step({?R, arg}, ship) do
    %A{ship|dir: rem(ship.dir+div(arg, 90)+@ndirs, @ndirs)}
  end
  def step({?L, arg}, ship) do
    %A{ship|dir: rem(ship.dir-div(arg, 90)+@ndirs, @ndirs)}
  end
  def step({?F, arg}, ship) do
    {dx, dy} = Enum.at(@directions, ship.dir)
    %A{ship | x: ship.x + dx * arg, y: ship.y + dy * arg}
  end

  def solve12a do
    parse()
    |> Enum.reduce(%A{}, &step/2)
    |> (fn %A{x: x, y: y} -> abs(x) + abs(y) end).()
    # 442 is too low
  end
end
