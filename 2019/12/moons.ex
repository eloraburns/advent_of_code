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

  @compile {:inline, [cmp: 2]}
  def cmp(a, b) when a > b, do: 1
  def cmp(a, b) when a == b, do: 0
  def cmp(a, b) when a < b, do: -1

  def apply_gravity(moons, previous_moons \\ [], acc \\ [])
  def apply_gravity([], _, acc), do: Enum.reverse(acc)
  def apply_gravity([moon | moons_after], moons_before, acc) do
    {dxa, dya, dza} = Stream.concat(moons_after, moons_before)
    |> Enum.reduce({0, 0, 0}, fn m, {dxxa, dyya, dzza} ->
      {
        dxxa + cmp(m.x, moon.x),
        dyya + cmp(m.y, moon.y),
        dzza + cmp(m.z, moon.z),
      }
    end)
    apply_gravity(
      moons_after,
      [moon | moons_before],
      [
        %M{ moon |
          dx: moon.dx + dxa,
          dy: moon.dy + dya,
          dz: moon.dz + dza,
        }
        | acc
      ]
    )
  end

  def apply_velocity(moons) do
    moons
    |> Enum.map(fn m ->
      %M{
        m |
        x: m.x + m.dx,
        y: m.y + m.dy,
        z: m.z + m.dz,
      }
    end)
  end

  def power(moons) do
    moons
    |> Enum.map(fn m ->
      (abs(m.x) + abs(m.y) + abs(m.z))
      *
      (abs(m.dx) + abs(m.dy) + abs(m.dz))
    end)
    |> Enum.sum
  end

  def solve_1a(filename \\ "input.txt", rounds \\ 1000) do
    moons = load!(filename)
    Enum.reduce(1..rounds, moons, fn _, acc ->
      acc |> apply_gravity |> apply_velocity
    end)
    |> power
  end
end
