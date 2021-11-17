defmodule Bugs do
  import Bitwise

  def load!(filename \\ "input.txt") do
    [
      b00, b10, b20, b30, b40,
      b01, b11, b21, b31, b41,
      b02, b12, b22, b32, b42,
      b03, b13, b23, b33, b43,
      b04, b14, b24, b34, b44,
    ] = File.stream!(filename)
    |> Enum.map(&String.trim/1)
    |> Enum.join("")
    |> String.split("", trim: true)
    |> Enum.map(fn
      "#" ->  1
      _ -> 0
    end)
    << b00 :: size(1), b10 :: size(1), b20 :: size(1), b30 :: size(1), b40 :: size(1), b01 :: size(1), b11 :: size(1), b21 :: size(1), b31 :: size(1), b41 :: size(1), b02 :: size(1), b12 :: size(1), b22 :: size(1), b32 :: size(1), b42 :: size(1), b03 :: size(1), b13 :: size(1), b23 :: size(1), b33 :: size(1), b43 :: size(1), b04 :: size(1), b14 :: size(1), b24 :: size(1), b34 :: size(1), b44 :: size(1) >>
  end

  @compile {:inline, c: 1}
  def c(1), do: "#"
  def c(0), do: "."

  def show(<< b00 :: size(1), b10 :: size(1), b20 :: size(1), b30 :: size(1), b40 :: size(1), b01 :: size(1), b11 :: size(1), b21 :: size(1), b31 :: size(1), b41 :: size(1), b02 :: size(1), b12 :: size(1), b22 :: size(1), b32 :: size(1), b42 :: size(1), b03 :: size(1), b13 :: size(1), b23 :: size(1), b33 :: size(1), b43 :: size(1), b04 :: size(1), b14 :: size(1), b24 :: size(1), b34 :: size(1), b44 :: size(1) >>) do
    "#{c(b00)}#{c(b10)}#{c(b20)}#{c(b30)}#{c(b40)}\n#{c(b01)}#{c(b11)}#{c(b21)}#{c(b31)}#{c(b41)}\n#{c(b02)}#{c(b12)}#{c(b22)}#{c(b32)}#{c(b42)}\n#{c(b03)}#{c(b13)}#{c(b23)}#{c(b33)}#{c(b43)}\n#{c(b04)}#{c(b14)}#{c(b24)}#{c(b34)}#{c(b44)}"
  end
end
