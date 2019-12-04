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
  {d, d, y, _, _, _} when d != y -> true
  {x, d, d, y, _, _} when x != d and d != y -> true
  {_, x, d, d, y, _} when x != d and d != y -> true
  {_, _, x, d, d, y} when x != d and d != y -> true
  {_, _, _, x, d, d} when x != d-> true
  _ -> false
end)
|> Enum.filter(fn pin ->
  {1, 9, 3, 6, 5, 1} < pin and pin < {6, 4, 9, 7, 2, 9}
end)
|> length
#|> Enum.map(&inspect/1)
#|> Enum.join("\n")
|> IO.puts

