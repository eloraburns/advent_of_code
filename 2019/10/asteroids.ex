defmodule Asteroids do
  def load!(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      Enum.with_index(line)
      |> Enum.flat_map(fn
        {"#", x} -> [{x, y}]
        _ -> []
      end)
    end)
    |> MapSet.new
  end

  def can_see_n({this_x, this_y} = this_asteroid, asteroids) do
    asteroids
    |> MapSet.delete(this_asteroid)
    |> Enum.map(fn {other_x, other_y} ->
      # This is the vector from here to the other asteroid
      dx = other_x - this_x
      dy = other_y - this_y
      # The gcd lets us normalize the vector to smallest form.
      gcd = Integer.gcd(dx, dy)
      # Any two vectors that reduce to the same base are by definition colinear, and nothing else is.
      {div(dx, gcd), div(dy, gcd)}
    end)
    |> MapSet.new
    |> MapSet.size
  end

  def total_vector_ordering(dx, dy)
  def total_vector_ordering(dx, dy) when dx == 0 and dy < 0,  do: {0, 0}
  def total_vector_ordering(dx, dy) when dx > 0  and dy < 0,  do: {1, -dx/dy}
  def total_vector_ordering(dx, dy) when dx > 0  and dy == 0, do: {2, 0}
  def total_vector_ordering(dx, dy) when dx > 0  and dy > 0,  do: {3, -dx/dy}
  def total_vector_ordering(dx, dy) when dx == 0 and dy > 0,  do: {4, 0}
  def total_vector_ordering(dx, dy) when dx < 0  and dy > 0,  do: {5, -dx/dy}
  def total_vector_ordering(dx, dy) when dx < 0  and dy == 0, do: {6, 0}
  def total_vector_ordering(dx, dy) when dx < 0  and dy < 0,  do: {7, -dx/dy}

  def solve_1a(filename \\ "input.txt") do
    asteroids = load!(filename)
    asteroids
    |> Enum.map(fn asteroid ->
      {can_see_n(asteroid, asteroids), asteroid}
    end)
    |> Enum.max
  end

  def solve_1b(filename \\ "input.txt") do
    asteroids = load!(filename)
    {_, {this_x, this_y} = laser_base} = solve_1a(filename)
    targets = MapSet.delete(asteroids, laser_base)
    # Grouping by vector
    Enum.group_by(targets, fn {other_x, other_y} ->
      # This is the vector from here to the other asteroid
      dx = other_x - this_x
      dy = other_y - this_y
      # The gcd lets us normalize the vector to smallest form.
      gcd = Integer.gcd(dx, dy)
      # Any two vectors that reduce to the same base are by definition colinear, and nothing else is.
      {div(dx, gcd), div(dy, gcd)}
    end)
    |> Enum.flat_map(fn {{vx, vy}, v_asteroids} ->
      v_order = total_vector_ordering(vx, vy)
      v_asteroids
      # Sort the asteroids on this vector by their distance
      |> Enum.sort_by(fn {x, y} -> abs((x - this_x) * (y - this_y)) end)
      |> Enum.with_index
      |> Enum.map(fn {a, i} -> {i, v_order, a} end)
    end)
    |> Enum.sort
    |> Enum.drop(199)
    |> hd
  end
end
