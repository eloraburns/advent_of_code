defmodule A do
  @required ~w(byr iyr eyr hgt hcl ecl pid)

  def add_line(m, {current, acc}) when map_size(m) == 0 do
    {%{}, [current | acc]}
  end
  def add_line(m, {current, acc}) do
    {Map.merge(m, current), acc}
  end

  def parse_line(l) do
    l
    |> String.trim
    |> String.split(" ", trim: true)
    |> Enum.map(fn kv ->
      kv
      |> String.split(":", parts: 2)
      |> List.to_tuple
    end)
    |> Enum.into(%{})
  end

  def parse(lines) do
    ca = lines
    |> Enum.map(&parse_line/1)
    |> Enum.reduce({%{}, []}, &add_line/2)

    {_, acc} = add_line(%{}, ca)
    acc
  end

  def solve do
    File.stream!("input.txt")
    |> parse
    |> Enum.count(fn passport ->
      passport
      |> Map.take(@required)
      |> map_size
      |> Kernel.==(length(@required))
    end)
  end

  def test do
    [
      "a:1 b:2\n",
      "c:3 d:4\n",
      "\n",
      "g:8\n"
    ]
    |> parse
  end
end
