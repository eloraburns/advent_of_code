defmodule A do
  def parse(filename \\ "input.txt") do
    filename
    |> File.read!
    |> String.split
    |> tl |> hd
    |> String.trim
    |> String.split(",")
    |> Enum.with_index
    |> Enum.flat_map(fn
      {"x", _} -> []
      {n, ix} -> [{String.to_integer(n), ix}]
    end)
  end

  def find_rem_point(tn, tm, _n, _m, d) when tm - tn == d, do: tn
  def find_rem_point(tn, tm, n, m, d) when tn < tm do
    find_rem_point(tn + n, tm, n, m, d)
  end
  def find_rem_point(tn, _tm, n, m, d) do
    find_rem_point(tn, div(tn + m, m) * m, n, m, d)
  end

  def rowreduce(m) do
    m
    |> Enum.map(fn
      [h|_] = row when h < 0 -> Enum.map(row, &(-&1))
      row -> row
    end)
    |> Enum.sort(:desc)
    |> do_rowreduce
  end

  def do_rowreduce([_] = m), do: m
  def do_rowreduce(m) do
    #require IEx; IEx.pry
    {rows, rows_with_leading_zeros, lowest_nonzero} = Enum.reduce(tl(m), {[], [], hd(m)}, fn
      row, {accr, accz, lowest_nonzero} when hd(row) == 0 ->
        {accr, [row | accz], lowest_nonzero}
      row, {accr, accz, lowest_nonzero} when row < lowest_nonzero ->
        {[lowest_nonzero | accr], accz, row}
      row, {accr, accz, lowest_nonzero} ->
        {[row | accr], accz, lowest_nonzero}
    end)
    
    if Enum.empty?(rows) do
      # lowest_nonzero is the top row
      # All other rows have a 0 in the first column
      # Then recurse on the inner data
      # And stitch it back together
      [lowest_nonzero | 
        rows_with_leading_zeros
        |> Enum.map(&tl/1)
        |> Enum.map(fn
          [h|_] = row when h < 0 -> Enum.map(row, &(-&1))
          row -> row
        end)
        |> Enum.sort(:desc)
        |> do_rowreduce
        |> Enum.map(&([0 | &1]))
      ]
    else
      ([lowest_nonzero |
        Enum.map(rows, fn r ->
          multiplier = div(hd(r), hd(lowest_nonzero))
          r
          |> Enum.zip(lowest_nonzero)
          |> Enum.map(fn {a, b} -> a - b*multiplier end)
        end)
      ] ++ rows_with_leading_zeros)
      |> Enum.sort(:desc)
      |> do_rowreduce
    end
  end

  def transpose(m) do
    m |> Enum.zip |> Enum.map(&Tuple.to_list/1)
  end

  def append_identity(m) do
    blank = 1..length(m) |> Enum.map(fn _ -> 0 end)
    m
    |> Enum.with_index
    |> Enum.map(fn {left_side, i} ->
      left_side ++ List.replace_at(blank, i, 1)
    end)
  end

  def split_right(m) do
    right_size = length(m)
    left_size = length(hd(m)) - right_size
    m
    |> Enum.map(fn r ->
      [Enum.take(r, left_size), Enum.drop(r, left_size)]
    end)
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
  end

  # [
  #   [1, 0, 0, 0, 0, 0, 0, 0, 0],                                                       [k1    [9
  #   [247, 1, 0, 0, 0, 0, 0, 0, 0],                                                      k2     19
  #   [247, 158916, 1, 0, 0, 0, 0, 0, 0],                                                 k3     27
  #   [247, 158916, -669161, 1, 0, 0, 0, 0, 0],                                        *  k4  =  32
  #   [247, 158916, -669161, -61562812, 1, 0, 0, 0, 0],                                   k5     36
  #   [247, 158916, -669161, -61562812, -1600633112, 1, 0, 0, 0],                         k6     48
  #   [247, 158916, -669161, -61562812, -1600633112, -23809417541, 1, 0, 0],              k7     50
  #   [247, 158916, -669161, -61562812, -1600633112, -23809417541, -5622423885039, 1, 0]  k8]    87]
  # ]
  # 1k1 = 9  =>  k1 = 9
  # 247*9 + 1k2 = 19  =>  k2 = 19 - 247*9 = -2204
  # 247*9 + 158916(-2204) + 1k3 = 27  =>  247*9 + 158916*(-2204) + k3 = 27  => k3 = 27 - 247*9 + 158916*2204

  # [1], 9 => [9]
  # [247, 1], 19 => [9, -2204]
  # [247, 158916, 1], 27 => [9, -2204, 350248668]
  # etc

  def solve_kn(a_l_t, offsets) do
    [{{[1, 0 | _], first_offset}, _} | rest_rows] = a_l_t
    |> Enum.zip(offsets)
    |> Enum.with_index

    (Enum.reduce(rest_rows, [first_offset], fn {{row, offset}, i}, acc ->
      acc ++ [
        offset - (
          row
          |> Enum.take(i)
          |> Enum.zip(acc)
          |> Enum.map(fn {a, b} -> a * b end)
          |> Enum.sum
        )
      ]
    end) |> hd) ++ [0]
  end

  def fake_dot(m, v) do
    #require IEx; IEx.pry
    Enum.map(m, fn r ->
      Enum.zip(r, v)
      |> Enum.map(fn {a, b} -> a * b end)
      |> Enum.sum
    end)
  end

  def mod(x, y) when x > 0, do: rem(x, y)
  def mod(x, y) when x < 0, do: y + rem(x, y)
  def mod(0, _), do: 0

  # Let's see…do I really want to implement a linear equation solver?
  # https://www.math.uwaterloo.ca/~wgilbert/Research/GilbertPathria.pdf

  def solve([{ft, 0} | rest]) do
    num_rows = length(rest)
    blank = 1..num_rows |> Enum.map(fn _ -> 0 end)
    a = [
      1..num_rows |> Enum.map(fn _ -> -ft end)
      |
      rest
      |> Enum.with_index
      |> Enum.map(fn {{x, _dt}, i} -> List.replace_at(blank, i, x) end)
    ]
    |> append_identity
    |> rowreduce

    [a_l, a_r] = split_right(a)

    offsets = [rest |> Enum.map(&elem(&1, 1))]
    k = solve_kn(transpose(a_l), offsets)

    k_offsets = fake_dot(transpose(a_r), k)

    c0 = hd(k_offsets)
    kc0 = transpose(a_r) |> hd |> Enum.reverse |> hd
    better_c0 = mod(c0, kc0)
 
    ft * better_c0
  end


  def tests do
    [
      {"test1.txt", 3417},
      {"test2.txt", 754018},
      {"test3.txt", 779210},
      {"test4.txt", 1261476},
      {"test5.txt", 1202161486},
    ]
    |> Enum.map(fn {f, n} ->
      case f |> parse |> solve do
        ^n -> IO.puts "ok #{n}"
        bad -> IO.puts "bad #{inspect bad} != #{n}"
      end
    end)
  end

  def test13b do
    IO.puts "Expect 1068781"
    "test.txt"
    |> parse
    |> solve
  end

  def solve13b do
    # https://www.wolframalpha.com/input/?i=19n+%3D+41m+-+9+%3D+859o+-+19+%3D+23p+-+27+%3D+13q+-+32+%3D+17r+-+36+%3D+29s+-+48+%3D+373t-50%3D37u-87
    IO.puts "WA expects #{19*47668123171408}"
    "input.txt"
    |> parse
    |> solve
  end
end
