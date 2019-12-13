defmodule Moons do
  defmodule M do
    defstruct [
      x: 0,
      y: 0,
      z: 0,
      dx: 0,
      dy: 0,
      dz: 0,
    ]
  end

  def load!(filename \\ "input.txt") do
    File.stream!(filename)
    |> Enum.map(fn l ->
      [x, y, z] = l
      |> String.trim
      |> fn ell -> Regex.run(~r/(-?\d+),.*?(-?\d+),.*?(-?\d+)/, ell) end.()
      |> tl
      |> Enum.map(&String.to_integer/1)
      %M{x: x, y: y, z: z}
    end)
  end

  def moons2axes([m1, m2, m3, m4]) do
    [
      {m1.x, 0, m2.x, 0, m3.x, 0, m4.x, 0},
      {m1.y, 0, m2.y, 0, m3.y, 0, m4.y, 0},
      {m1.z, 0, m2.z, 0, m3.z, 0, m4.z, 0},
    ]
  end

  @compile {:inline, cmp: 2}
  def cmp(a, b) when a > b, do: 1
  def cmp(a, b) when a == b, do: 0
  def cmp(a, b) when a < b, do: -1

  @compile {:inline, apply_gravity: 1}
  def apply_gravity({x1, dx1, x2, dx2, x3, dx3, x4, dx4}) do
    {
      x1,
      dx1 + cmp(x2, x1) + cmp(x3, x1) + cmp(x4, x1),
      x2,
      dx2 + cmp(x1, x2) + cmp(x3, x2) + cmp(x4, x2),
      x3,
      dx3 + cmp(x1, x3) + cmp(x2, x3) + cmp(x4, x3),
      x4,
      dx4 + cmp(x1, x4) + cmp(x2, x4) + cmp(x3, x4),
    }
  end

  @compile {:inline, apply_velocity: 1}
  def apply_velocity({x1, dx1, x2, dx2, x3, dx3, x4, dx4}) do
    {
      x1 + dx1, dx1,
      x2 + dx2, dx2,
      x3 + dx3, dx3,
      x4 + dx4, dx4,
    }
  end

  def find_period(axis), do: find_period(axis |> apply_gravity |> apply_velocity, axis, 1)
  def find_period(axis, axis, period), do: period
  def find_period(axis, origin, period), do: find_period(axis |> apply_gravity |> apply_velocity, origin, period + 1)

  def solve_1a(filename \\ "input.txt", rounds \\ 1000) do
    axes = load!(filename) |> moons2axes
    [
      {x1, dx1, x2, dx2, x3, dx3, x4, dx4},
      {y1, dy1, y2, dy2, y3, dy3, y4, dy4},
      {z1, dz1, z2, dz2, z3, dz3, z4, dz4},
    ] = Enum.reduce(1..rounds, axes, fn _, [ax, ay, az] ->
      [
        ax |> apply_gravity |> apply_velocity,
        ay |> apply_gravity |> apply_velocity,
        az |> apply_gravity |> apply_velocity,
      ]
    end)
    (
      (abs(x1) + abs(y1) + abs(z1)) * (abs(dx1) + abs(dy1) + abs(dz1)) +
      (abs(x2) + abs(y2) + abs(z2)) * (abs(dx2) + abs(dy2) + abs(dz2)) +
      (abs(x3) + abs(y3) + abs(z3)) * (abs(dx3) + abs(dy3) + abs(dz3)) +
      (abs(x4) + abs(y4) + abs(z4)) * (abs(dx4) + abs(dy4) + abs(dz4))
    )
  end

  def solve_1b(filename \\ "input.txt") do
    periods = load!(filename)
    |> moons2axes
    |> Enum.map(&__MODULE__.find_period/1)

    base = Enum.reduce(periods, &Integer.gcd/2)

    periods
    |> Enum.map(&div(&1, base))
    |> Enum.reduce(&Kernel.*/2)
  end
end
