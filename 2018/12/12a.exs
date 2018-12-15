defmodule Twelve do
  content = File.read!("input.txt")
  [<<"initial state: ", initial_state::binary>>, "" | rules] = String.split(content, "\n")

  @initial_state {:left, 0, String.to_charlist(initial_state)}

  for <<p0, p1, p2, p3, p4, " => ", result>> <- rules do
    def transform(:left, [unquote(p0), unquote(p1), unquote(p2), unquote(p3), unquote(p4) | _]), do: unquote(result)
    def transform(:right, [unquote(p4), unquote(p3), unquote(p2), unquote(p1), unquote(p0) | _]), do: unquote(result)
    if p4 == ?. do
      def transform(:left, [unquote(p0), unquote(p1), unquote(p2), unquote(p3)]), do: unquote(result)
      if p3 == ?. do
        def transform(:left, [unquote(p0), unquote(p1), unquote(p2)]), do: unquote(result)
        if p2 == ?. do
          def transform(:left, [unquote(p0), unquote(p1)]), do: unquote(result)
          if p1 == ?. do
            def transform(:left, [unquote(p0)]), do: unquote(result)
          end
        end
      end
    end
    if p0 == ?. do
      def transform(:right, [unquote(p4), unquote(p3), unquote(p2), unquote(p1)]), do: unquote(result)
      if p1 == ?. do
        def transform(:right, [unquote(p4), unquote(p3), unquote(p2)]), do: unquote(result)
        if p2 == ?. do
          def transform(:right, [unquote(p4), unquote(p3)]), do: unquote(result)
          if p3 == ?. do
            def transform(:right, [unquote(p4)]), do: unquote(result)
          end
        end
      end
    end
  end
  # Fallthrough for the sample code.
  def transform(_), do: ?.

  def trim({:left, offset, [?. | state]}), do: trim({:left, offset + 1, state})
  def trim({:right, offset, [?. | state]}), do: trim({:right, offset - 1, state})
  def trim(x), do: x

  def step({:left, offset, state}) do
    step(:left, offset - 2, [?., ?., ?., ?. | state], [])
  end
  def step({:right, offset, state}) do
    step(:right, offset + 2, [?., ?., ?., ?. | state], [])
  end

  def step(:left, offset, [], acc), do: {:right, offset, acc} |> trim
  def step(:right, offset, [], acc), do: {:left, offset, acc} |> trim
  def step(:left, offset, state, acc) do
    step(:left, offset + 1, tl(state), [transform(:left, state) | acc])
  end
  def step(:right, offset, state, acc) do
    step(:right, offset - 1, tl(state), [transform(:right, state) | acc])
  end

  def solve(iters \\ 20) do
    {d, o, s} = Enum.reduce(1..iters, @initial_state, fn _, s -> step(s) end)
    it = case d do
      :left -> fn i -> i + 1 end
      :right -> fn i -> i - 1 end
    end
    Enum.zip(Stream.iterate(o, it), s)
    |> Enum.map(fn
      {v, ?#} -> v
      {_, ?.} -> 0
    end)
    |> Enum.sum
  end

end
