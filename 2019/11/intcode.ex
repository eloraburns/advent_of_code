defmodule Intcode do
  defstruct [:name, :program, :ip, :relative_base, :last_output, :wired_to, :report_to]

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

  def run(intcode, step \\ false, halt \\ false)
  def run(intcode, _, true), do: intcode
  def run(intcode, step, _) do
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
        |> run(false, step)

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
        |> run(false, step)

      3 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 1),
            receive do
              {:input, x} -> x
            end,
            intcode.program
          ),
          ip: intcode.ip + 2
        }
        |> run(false, step)

      4 ->
        try do
          send intcode.wired_to, {:input, arg_value(intcode, opcode, 1)}
        rescue
          ArgumentError -> nil
        end
        %__MODULE__{
          intcode | 
          last_output: arg_value(intcode, opcode, 1),
          ip: intcode.ip + 2
        }
        |> run(false, step)

      5 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) != 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run(false, step)

      6 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) == 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run(false, step)

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
        |> run(false, step)

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
        |> run(false, step)

      9 ->
        %__MODULE__{
          intcode |
          ip: intcode.ip + 2,
          relative_base: intcode.relative_base + arg_value(intcode, opcode, 1),
        }
        |> run(false, step)

      99 ->
        if intcode.report_to do
          send intcode.report_to, {:result, intcode.last_output}
        end
    end
  end

  defmodule Bot do
    defstruct [
      direction: 0,
      x: 0,
      y: 0,
      # {x, y} -> 1 | 0
      hull: Map.new,
      # [{x1, y1}, {x2, y2}]
      painted: MapSet.new,
    ]
  end

  @directions [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
  
  def botstep(%Bot{} = state, bot) do
    send bot, {:input, Map.get(state.hull, {state.x, state.y}, 0)}
    receive do
      {:input, colour} ->
        rotation = receive do
          {:input, 0} -> -1
          {:input, 1} -> 1
        end
        new_direction = rem(state.direction + rotation, 4)
        {dx, dy} = Enum.at(@directions, new_direction)
        %Bot{ state |
          direction: new_direction,
          x: state.x + dx,
          y: state.y + dy,
          hull: Map.put(state.hull, {state.x, state.y}, colour),
          painted: MapSet.put(state.painted, {state.x, state.y}),
        }
        |> botstep(bot)
      {:result, _} -> state
    end
  end

  def the_bot(filename \\ "input.txt") do
    program = load!(filename)
    runner_pid = self()
    spawn(fn -> run(%__MODULE__{program | name: :bot, wired_to: runner_pid, report_to: runner_pid}) end)
  end

  def render(hull) do
    [{xmin, xmax}, {ymin, ymax}] = hull
    |> Map.keys
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.zip
    |> Enum.map(&(&1 |> Tuple.to_list |> Enum.min_max))

    for x <- xmin..xmax do
      for y <- ymin..ymax do
        if Map.get(hull, {x, y}, 0) == 1 do "*" else " " end
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
  end

  def answer_1a(filename \\ "input.txt") do
    bot = the_bot(filename)
    botstep(%Bot{}, bot)
    |> Map.get(:hull)
    |> render
    |> IO.puts
    #|> Map.get(:painted)
    #|> MapSet.size
  end

  def answer_1b(filename \\ "input.txt") do
    bot = the_bot(filename)
    botstep(%Bot{hull: %{{0, 0} => 1}}, bot)
    |> Map.get(:hull)
    |> render
    |> IO.puts
  end
end
