defmodule Redox do
  defmodule Reaction do
    defstruct [
      :components,
      :product,
      :product_qty,
    ]
  end

  def load!(filename) do
    File.stream!(filename)
    |> Enum.map(fn l ->
      [components, product] = l |> String.trim |> String.split(" => ")
      {prod, prod_qty} = qty_of(product)
      {
        prod,
        %Reaction{
          components: 
            components
            |> String.split(", ")
            |> Enum.map(&qty_of/1),
          product: prod,
          product_qty: prod_qty,
        }
      }
    end)
    |> Map.new
  end

  def qty_of(s) do
    [amount, thing] = String.split(s)
    {thing, String.to_integer(amount)}
  end

  def test1, do: 31 = solve_1a("test1.txt")
  def test2, do: 165 = solve_1a("test2.txt")
  def test3, do: 13312 = solve_1a("test3.txt")
  def test4, do: 180697 = solve_1a("test4.txt")
  def test5, do: 2210736 = solve_1a("test5.txt")

  def test3b, do: 82892753 = solve_1b("test3.txt")
  def test4b, do: 5586022 = solve_1b("test4.txt")
  def test5b, do: 460664 = solve_1b("test5.txt")

  defmodule Supply do
    defstruct leftover: %{}, need: %{"FUEL" => 1}, ore: 0
  end

  def step(supply, reactions) do
    Enum.reduce(supply.need, %Supply{ supply | need: %{} }, fn
      {"ORE", q}, s -> %Supply{ s | ore: s.ore + q }
      {c, q}, s ->
        case Map.get(s.leftover, c, 0) do
          left when left >= q ->
            # take some
            %Supply{ s | leftover: s.leftover |> Map.put(c, left - q) }
          left ->
            # make some
            r = Map.get(reactions, c)
            shortfall = q - left
            num_reactions = ceil(shortfall / r.product_qty)
            net_new = num_reactions * r.product_qty
            new_left = left + net_new - q

            reaction_needs = Enum.map(r.components, fn {r_c, r_q} -> {r_c, r_q * num_reactions} end) |> Map.new
            ore_needs = Map.get(reaction_needs, "ORE", 0)
            %Supply{ s |
              leftover: s.leftover |> Map.put(c, new_left),
              need: Map.merge(s.need, reaction_needs |> Map.drop(["ORE"]), fn _k, v1, v2 -> v1 + v2 end),
              ore: s.ore + ore_needs
            }
        end
    end)
  end

  def solve_1a(filename \\ "input.txt") do
    reactions = load!(filename)
    {%Supply{need: %{"FUEL" => 1}}, reactions}
    |> Stream.iterate(fn {s, r} -> {step(s, r), r} end)
    |> Stream.drop_while(fn {s, _r} -> map_size(s.need) > 0 end)
    |> Enum.take(1)
    |> (fn [{%{ore: ore}, _}] -> ore end).()
  end

  def solve_1b(filename \\ "input.txt", bootstrap_fuel \\ 3_340_000) do
    reactions = load!(filename)
    {%Supply{need: %{"FUEL" => bootstrap_fuel}}, reactions, bootstrap_fuel - 1}
    |> Stream.iterate(fn
      {%{need: n} = s, r, f} when map_size(n) == 0 ->
        {step(%Supply{ s | need: %{"FUEL" => 1}}, r), r, f + 1}
      {s, r, f} -> {step(s, r), r, f}
    end)
    |> Stream.drop_while(fn {%{ore: o}, _r, _f} -> o < 1_000_000_000_000 end)
    |> Enum.take(1)
    |> (fn [{_, _, f}] -> f end).()
    # 143478 is too low
    # 3343477
  end
end
