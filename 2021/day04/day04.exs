defmodule Day04 do
  def test do
    solvea("test.txt") |> IO.inspect(label: "testa")
    solveb("test.txt") |> IO.inspect(label: "testb")
  end

  def solve do
    solvea("input.txt") |> IO.inspect(label: "4a")
    solveb("input.txt") |> IO.inspect(label: "4b")
  end

  def solvea(filename) do
    {choices, boards} = parse(filename)

    Stream.scan(choices, {nil, boards}, fn choice, {_, boards} ->
      {
        choice,
        boards |> Enum.map(&mark_board(&1, choice))
      }
    end)
    |> Enum.find(fn {choice, boards} ->
      Enum.any?(boards, &winner?(&1))
    end)
    |> (fn {choice, boards} ->
      boards
      |> Enum.find(boards, &winner?(&1))
      |> Enum.concat
      |> Enum.map(fn
        {n, :unmarked} -> n
        _ -> 0
      end)
      |> Enum.sum
      |> Kernel.*(choice)
    end).()
  end

  def solveb(filename) do
    {choices, boards} = parse(filename)

    game = Stream.scan(choices, {nil, boards}, fn choice, {_, boards} ->
      {
        choice,
        boards |> Enum.map(&mark_board(&1, choice))
      }
    end)

    {final_choice, _} = Enum.find(game, fn {choice, boards} ->
      Enum.all?(boards, &winner?(&1))
    end)

    prev_choice = find_prev(choices, final_choice)
    
    Enum.find(game, fn
      {^prev_choice, boards} -> true
      _ -> false
    end)
    |> IO.inspect
    |> (fn {choice, boards} ->
      boards
      |> Enum.find(boards, fn board -> not winner?(board) end)
      |> mark_board(final_choice)
      |> Enum.concat
      |> Enum.map(fn
        {n, :unmarked} -> n
        _ -> 0
      end)
      |> Enum.sum
      |> Kernel.*(final_choice)
    end).()
  end

  def find_prev([prev, n | _], n), do: prev
  def find_prev([_ | rest], n), do: find_prev(rest, n)

  def parse(filename) do
    [choices_str | boards_str] = File.stream!(filename)
    |> Enum.to_list

    choices = choices_str
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    boards = boards_str
    |> Enum.chunk_every(6)
    |> Enum.map(fn board_lines ->
      board_lines
      |> tl
      |> Enum.map(fn l ->
        l
        |> String.trim
        |> String.split(" ", trim: true)
        |> Enum.map(fn n -> {n |> String.to_integer, :unmarked} end)
      end)
    end)
 
    {choices, boards}
  end

  def mark_board(board, number) do
    board
    |> Enum.map(fn row ->
      Enum.map(row, fn
        {^number, _} -> {number, :marked}
        other -> other
      end)
    end)
  end

  def winner?(board) do
    row_winner? = Enum.any?(board, fn row ->
      Enum.all?(row, fn
        {_, :marked} -> true
        _ -> false
      end)
    end)
    col_winner? = board
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.any?(fn row ->
      Enum.all?(row, fn
        {_, :marked} -> true
        _ -> false
      end)
    end)
    row_winner? or col_winner?
  end

end

Day04.test
Day04.solve
