defmodule A do
  defstruct [
    space: %{},
    x: %{min: 0, max: 0},
    y: %{min: 0, max: 0},
    z: %{min: 0, max: 0}
  ]

  def to_struct(input) do
    s = for {line, y} <- Enum.with_index(input),
      {c, x} <- line |> String.trim |> String.to_charlist |> Enum.with_index do
        {{x, y, 0}, c}
    end
    |> Map.new

    {maxx, maxy} = s |> Map.keys |> Enum.reduce({0, 0}, fn {x, y, _}, {maxx, maxy} ->
      {max(x, maxx), max(y, maxy)}
    end)
      
    %A{
      space: s,
      x: %{min: 0, max: maxx},
      y: %{min: 0, max: maxy}
    }
  end

  def is_block(?#), do: true
  def is_block(?.), do: false

  def neighbour_count(m, x, y, z) do
    for zi <- [z - 1, z, z + 1],
      yi <- [y - 1, y, y + 1],
      xi <- [x - 1, x, x + 1],
      zi != z or yi != y or xi != x do
        Map.get(m.space, {xi, yi, zi}, ?.)
    end
    |> Enum.count(&is_block/1)
  end

  def step(m) do
    s = for z <- (m.z.min-1)..(m.z.max+1) do
      for y <- (m.y.min-1)..(m.y.max+1) do
        for x <- (m.x.min-1)..(m.x.max+1) do
          num_neighbours = neighbour_count(m, x, y, z)
          this_block = case Map.get(m.space, {x, y, z}, ?.) do
            ?# when num_neighbours == 2 or num_neighbours == 3 -> ?#
            ?. when num_neighbours == 3 -> ?#
            _ -> ?.
          end
          {{x, y, z}, this_block}
        end
      end
      |> Enum.concat
    end
    |> Enum.concat
    |> Map.new
      
    %A{
      space: s,
      x: %{min: m.x.min-1, max: m.x.max+1},
      y: %{min: m.y.min-1, max: m.y.max+1},
      z: %{min: m.z.min-1, max: m.z.max+1}
    }
  end

  def count(m) do
    m.space
    |> Map.values
    |> Enum.count(&is_block/1)
  end

  def splat(m) do
    IO.puts m
    m
  end

  def test17a do
    IO.puts "Expect 112"
    File.stream!("test.txt")
    |> to_struct
    |> step
    |> splat
    |> step
    |> splat
    |> step
    |> splat
    |> step
    |> splat
    |> step
    |> splat
    |> step
    |> splat
    |> count
  end

  def solve17a do
    File.stream!("input.txt")
    |> to_struct
    |> step
    |> step
    |> step
    |> step
    |> step
    |> step
    |> count
  end

  def tests do
    test_m = File.stream!("test.txt") |> to_struct
    4 = neighbour_count(test_m, 1, 1, 0)
  end
end

defimpl String.Chars, for: A do
  def to_string(m) do
    for z <- m.z.min..m.z.max do
      for y <- m.y.min..m.y.max do
        for x <- m.x.min..m.x.max do
          Map.get(m.space, {x, y, z}, ?.)
        end
        |> Enum.concat([?\n])
      end
      |> Enum.concat([?\n, ?\n])
    end
    |> IO.iodata_to_binary
  end
end
