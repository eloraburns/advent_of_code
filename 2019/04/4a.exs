for d0 <- 1..7,
  d1 <- d0..9,
  d2 <- d1..9,
  d3 <- d2..9,
  d4 <- d3..9,
  d5 <- d4..9
do
  {d0, d1, d2, d3, d4, d5}
end
|> Enum.filter(fn
  {d, d, _, _, _, _} -> true
  {_, d, d, _, _, _} -> true
  {_, _, d, d, _, _} -> true
  {_, _, _, d, d, _} -> true
  {_, _, _, _, d, d} -> true
  _ -> false
end)
|> Enum.filter(fn pin ->
  {1, 9, 3, 6, 5, 1} < pin and pin < {6, 4, 9, 7, 2, 9}
end)
|> length
#|> Enum.map(&inspect/1)
#|> Enum.join("\n")
|> IO.puts

#1660 is someone else's and is too high
#1604 is too low
