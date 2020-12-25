defmodule Crypto do
  @subject 7
  @mod 20201227

  def crypt(input, subject), do: rem(input * subject, @mod)

  def crypt_stream(subject \\ @subject) do
    1
    |> Stream.iterate(&Crypto.crypt(&1, subject))
    |> Stream.with_index
  end

  def find_loop_value_for(n, subject \\ @subject) do
    crypt_stream(subject)
    |> Stream.drop_while(&(elem(&1, 0) != n))
    |> Enum.take(1)
    |> hd
    |> elem(1)
  end

  def value_at_loop(loop_num, subject \\ @subject) do
    crypt_stream(subject)
    |> Stream.drop(loop_num)
    |> Enum.take(1)
    |> hd
    |> elem(0)
  end

  def solvea(filename) do
    [key_pub, door_pub] = filename
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)

    IO.inspect {:keys, key_pub, door_pub}

    key_loop = find_loop_value_for(key_pub)
    door_loop = find_loop_value_for(door_pub)

    IO.inspect {:loops, key_loop, door_loop}

    {
      value_at_loop(door_loop, key_pub),
      value_at_loop(key_loop, door_pub),
    }
  end

  def test25a do
    solvea("test.txt")
  end

  def solve25a do
    solvea("input.txt")
  end
end
