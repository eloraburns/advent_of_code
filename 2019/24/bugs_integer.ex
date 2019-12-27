defmodule Bugs do
  import Bitwise

  def load!(filename \\ "input.txt") do
    File.stream!(filename)
    |> Enum.map(&String.trim/1)
    |> Enum.join("")
    |> String.split("", trim: true)
    |> Enum.with_index
    |> Enum.map(fn
      {"#", i} -> 1 <<< i
      _ -> 0
    end)
    |> Enum.sum
  end

  def show(board) do
    for y <- [0, 5, 10, 15, 20] do
      for x <- [1, 2, 4, 8, 16] do
        case (board &&& (x <<< y)) > 0 do
          true -> "#"
          false -> "."
        end
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
  end

  @compile {:inline, bug?: 2}
  def bug?(bug, board), do: ((board >>> bug) &&& 1) == 1

  @compile {:inline, mask: 1}
  def mask(bug) do
    if bug in [0, 5, 10, 15, 20] do 0 else 1 <<< (bug-1) end |||
    if bug in [0, 1, 2, 3, 4] do 0 else 1 <<< (bug-5) end |||
    if bug in [20, 21, 22, 23, 24] do 0 else 1 <<< (bug+5) end |||
    if bug in [4, 9, 14, 19, 24] do 0 else 1 <<< (bug+1) end
  end

  @compile {:inline, population: 1}
  def population(i) do
    i2 = (0b01010101010101010101010101010101 &&& i) + ((0b10101010101010101010101010101010 &&& i) >>> 1)
    i3 = (0b00110011001100110011001100110011 &&& i2) + ((0b11001100110011001100110011001100 &&& i2) >>> 2)
    i4 = (0b00001111000011110000111100001111 &&& i3) + ((0b11110000111100001111000011110000 &&& i3) >>> 4)
    i5 = (0b00000000111111110000000011111111 &&& i4) + ((0b11111111000000001111111100000000 &&& i4) >>> 8)
    (0b00000000000000001111111111111111 &&& i5) + ((0b11111111111111110000000000000000 &&& i5) >>> 16)
  end

  def next(bug, board) do
    neighbours = (mask(bug) &&& board) |> population
    live? = bug?(bug, board)
    if (live? and neighbours == 1) or (not live? and (neighbours == 1 or neighbours == 2)) do
      1 <<< bug
    else
      0
    end
  end

  def step(board) do
    0..24
    |> Enum.map(&next(&1, board))
    |> Enum.reduce(&Bitwise.bor/2)
  end

  def first_repeat(board, seen \\ MapSet.new) do
    if MapSet.member?(seen, board) do
      board
    else
      first_repeat(step(board), MapSet.put(seen, board))
    end
  end

  def solve_1a(filename \\ "input.txt") do
    board = load!(filename)
    first_repeat(board)
  end
end
