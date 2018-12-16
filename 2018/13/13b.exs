defmodule Thirteen do
  def load(filename \\ "input.txt") do
    File.stream!(filename)
    |> Enum.zip(Stream.iterate(0, &(&1 + 1)))
    |> Enum.flat_map(fn {line, lineno} ->
      Enum.zip(String.to_charlist(line), Stream.iterate(0, &(&1 + 1)))
      |> Enum.map(fn {c, colno} -> {{colno, lineno}, c} end)
    end)
    |> Enum.reduce({%{}, []}, fn
      {coord, track}, {board, carts} when track in '|-/\\+' -> {Map.put(board, coord, track), carts}
      {coord, ?^}, {board, carts} -> {Map.put(board, coord, ?|), [{coord, {:up, :next_left}} | carts]}
      {coord, ?v}, {board, carts} -> {Map.put(board, coord, ?|), [{coord, {:down, :next_left}} | carts]}
      {coord, ?<}, {board, carts} -> {Map.put(board, coord, ?-), [{coord, {:left, :next_left}} | carts]}
      {coord, ?>}, {board, carts} -> {Map.put(board, coord, ?-), [{coord, {:right, :next_left}} | carts]}
      _, state -> state
    end)
    |> (fn {board, carts} -> {board, Map.new(carts)} end).()
  end

  def step_cart(board, {x, y}, {:up, _} = d) do
    new_location = {x, y - 1}
    {new_location, step_cart_to(board[new_location], d)}
  end
  def step_cart(board, {x, y}, {:left, _} = d) do
    new_location = {x - 1, y}
    {new_location, step_cart_to(board[new_location], d)}
  end
  def step_cart(board, {x, y}, {:down, _} = d) do
    new_location = {x, y + 1}
    {new_location, step_cart_to(board[new_location], d)}
  end
  def step_cart(board, {x, y}, {:right, _} = d) do
    new_location = {x + 1, y}
    {new_location, step_cart_to(board[new_location], d)}
  end

  def step_cart_to(?|, d), do: d
  def step_cart_to(?-, d), do: d
  def step_cart_to(?\\, {:up,     disp}          ), do: {:left,  disp}
  def step_cart_to(?\\, {:left,   disp}          ), do: {:up,    disp}
  def step_cart_to(?\\, {:down,   disp}          ), do: {:right, disp}
  def step_cart_to(?\\, {:right,  disp}          ), do: {:down,  disp}
  def step_cart_to(?/,  {:up,     disp}          ), do: {:right, disp}
  def step_cart_to(?/,  {:left,   disp}          ), do: {:down,  disp}
  def step_cart_to(?/,  {:down,   disp}          ), do: {:left,  disp}
  def step_cart_to(?/,  {:right,  disp}          ), do: {:up,    disp}
  def step_cart_to(?+,  {:up,     :next_left}    ), do: {:left,  :next_straight}
  def step_cart_to(?+,  {:up,     :next_straight}), do: {:up,    :next_right}
  def step_cart_to(?+,  {:up,     :next_right}   ), do: {:right, :next_left}
  def step_cart_to(?+,  {:left,   :next_left}    ), do: {:down,  :next_straight}
  def step_cart_to(?+,  {:left,   :next_straight}), do: {:left,  :next_right}
  def step_cart_to(?+,  {:left,   :next_right}   ), do: {:up,    :next_left}
  def step_cart_to(?+,  {:down,   :next_left}    ), do: {:right, :next_straight}
  def step_cart_to(?+,  {:down,   :next_straight}), do: {:down,  :next_right}
  def step_cart_to(?+,  {:down,   :next_right}   ), do: {:left,  :next_left}
  def step_cart_to(?+,  {:right,  :next_left}    ), do: {:up,    :next_straight}
  def step_cart_to(?+,  {:right,  :next_straight}), do: {:right, :next_right}
  def step_cart_to(?+,  {:right,  :next_right}   ), do: {:down,  :next_left}

  def step({_, carts}) when map_size(carts) < 2, do: {:last, :cart, carts}
  def step({board, carts}) do
    {step_carts, crash_locations} = carts
      |> Map.keys
      |> Enum.sort
      |> Enum.reduce({carts, []}, fn coords, {cs, cl} ->
        if coords in cl do
          {cs, cl}
        else
          {ncoords, d} = step_cart(board, coords, cs[coords])
          if Map.has_key?(cs, ncoords) do
            {Map.drop(cs, [coords]), [ncoords | cl]}
          else
            {cs |> Map.drop([coords]) |> Map.put(ncoords, d), cl}
          end
        end
      end)
    {
      board,
      Map.drop(step_carts, crash_locations)
    }
  end

  def solve(filename \\ "input.txt") do
    load(filename)
    |> Stream.iterate(&step/1)
    |> Enum.drop_while(fn
      {:last, :cart, _} -> false
      _ -> true
    end)
    |> Enum.take(1)
    |> hd
  end
end
