defmodule Intcode do
  defstruct [:name, :program, :ip, :relative_base]

  def load!(filename) do
    %__MODULE__{
      program: File.read!(filename)
        |> String.split(",")
        |> Enum.map(fn x ->
          x |> String.trim |> String.to_integer
        end)
        |> :array.from_list(0),
      ip: 0,
      relative_base: 0,
    }
  end

  def peek(intcode, address) do
    :array.get(address, intcode.program)
  end

  def poke(intcode, address, value) do
    %__MODULE__{ intcode | program: :array.set(address, value, intcode.program) }
  end

  @compile {:inline, arg_address: 3}
  def arg_address(intcode, opcode, arg_number)
  def arg_address(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 0 do
    :array.get(intcode.ip + 1, intcode.program)
  end
  def arg_address(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 0 do
    :array.get(intcode.ip + 2, intcode.program)
  end
  def arg_address(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 0 do
    :array.get(intcode.ip + 3, intcode.program)
  end
  def arg_address(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 1 do
    intcode.ip + 1
  end
  def arg_address(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 1 do
    intcode.ip + 2
  end
  def arg_address(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 1 do
    intcode.ip + 3
  end
  def arg_address(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 2 do
    intcode.relative_base + :array.get(intcode.ip + 1, intcode.program)
  end
  def arg_address(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 2 do
    intcode.relative_base + :array.get(intcode.ip + 2, intcode.program)
  end
  def arg_address(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 2 do
    intcode.relative_base + :array.get(intcode.ip + 3, intcode.program)
  end

  @compile {:inline, arg_value: 3}
  def arg_value(intcode, opcode, arg_number) do
    :array.get(arg_address(intcode, opcode, arg_number), intcode.program)
  end

  def run(intcode, input \\ nil, step \\ false, halt \\ false)
  def run(intcode, _, _, true), do: intcode
  def run(intcode, input, step, _) do
    opcode = :array.get(intcode.ip, intcode.program)
    case rem(opcode, 100) do

      1 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            arg_value(intcode, opcode, 1) + arg_value(intcode, opcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        }
        |> run(input, false, step)

      2 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            arg_value(intcode, opcode, 1) * arg_value(intcode, opcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        }
        |> run(input, false, step)

      3 when is_nil(input) ->
        {:need_input, intcode}

      3 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 1),
            input,
            intcode.program
          ),
          ip: intcode.ip + 2
        }
        |> run(nil, false, step)

      4 ->
        {
          :made_output,
          arg_value(intcode, opcode, 1), 
          %__MODULE__{
            intcode | 
            ip: intcode.ip + 2
          }
        }

      5 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) != 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run(input, false, step)

      6 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) == 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run(input, false, step)

      7 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            if arg_value(intcode, opcode, 1) < arg_value(intcode, opcode, 2) do 1 else 0 end,
            intcode.program
          ),
          ip: intcode.ip + 4
        }
        |> run(input, false, step)

      8 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            if arg_value(intcode, opcode, 1) == arg_value(intcode, opcode, 2) do 1 else 0 end,
            intcode.program
          ),
          ip: intcode.ip + 4
        }
        |> run(input, false, step)

      9 ->
        %__MODULE__{
          intcode |
          ip: intcode.ip + 2,
          relative_base: intcode.relative_base + arg_value(intcode, opcode, 1),
        }
        |> run(input, false, step)

      99 ->
        {:halted, intcode}
    end
  end

  def print_board(board) do
    {maxx, maxy} = Map.keys(board)
    |> Enum.reduce({0, 0}, fn {x, y}, {maxx, maxy} ->
      {max(maxx, x), max(maxy, y)}
    end)

    IO.puts ([
      "-------------------------------------------------------",
      "-----------------------#{Map.get(board, {-1, 0}, 0)}-------------------------------"
      |
      for y <- 0..maxy do
        for x <- 0..maxx do
          case Map.get(board, {x, y}, 0) do
            0 -> " "
            1 -> "|"
            2 -> "#"
            3 -> "="
            4 -> "O"
          end
        end
        |> Enum.join("")
      end
    ]
    |> Enum.join("\n"))
    board
  end

  def find_in_board(board, tile) do
    Enum.reduce(board, nil, fn
      {{x, y}, ^tile}, nil -> {x, y}
      _, acc -> acc
    end)
  end

  def cmp(x, y) when x > y, do: 1
  def cmp(x, y) when x < y, do: -1
  def cmp(_, _), do: 0

  def game_runner(intcode, board \\ %{}, input \\ nil) do
    case run(intcode, input) do
      {:need_input, next} ->
        {ballx, _} = find_in_board(board, 4)
        {paddlex, _} = find_in_board(board, 3)
        game_runner(next, board, cmp(ballx, paddlex))
      {:made_output, x, next} ->
        {:made_output, y, next2} = run(next)
        {:made_output, z, next3} = run(next2)
        newboard = board |> Map.put({x, y}, z) |> print_board
        game_runner(next3, newboard)
      {:halted, next} -> {next, board}
    end
  end

  def answer_13b do
    load!("input.txt")
    |> poke(0, 2)
    |> game_runner
    |> elem(1)
    |> Map.get({-1, 0})
  end
end
