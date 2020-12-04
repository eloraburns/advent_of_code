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

  def validate({"byr", byr}) when byte_size(byr) == 4 and byr >= "1920" and byr <= "2002", do: true
  def validate({"iyr", iyr}) when byte_size(iyr) == 4 and iyr >= "2010" and iyr <= "2020", do: true
  def validate({"eyr", eyr}) when byte_size(eyr) == 4 and eyr >= "2020" and eyr <= "2030", do: true
  def validate({"hgt", <<in_cm::binary-size(3), "cm">>}) when in_cm >= "150" and in_cm <= "193", do: true
  def validate({"hgt", <<in_in::binary-size(2), "in">>}) when in_in >= "59" and in_in <= "76", do: true
  def validate({"hcl", hcl}), do: Regex.match?(~r/^#[0-9a-f]{6}$/, hcl)
  def validate({"ecl", ecl}) when ecl in ~w(amb blu brn gry grn hzl oth), do: true
  def validate({"pid", pid}), do: Regex.match?(~r/^\d{9}$/, pid)
  def validate({"cid", _}), do: true
  def validate({_, _}), do: false

  def valid?(%{"pid" => _, "hgt" => _, "ecl" => _, "iyr" => _, "eyr" => _, "byr" => _, "hcl" => _} = p) do
    Enum.all?(p, &validate/1)
  end
  def valid?(_), do: false

  def solve do
    File.stream!("input.txt")
    |> parse
    |> Enum.count(&valid?/1)
  end
end
