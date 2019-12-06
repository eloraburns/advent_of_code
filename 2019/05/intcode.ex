defmodule Intcode do
  defstruct [:program, :ip]

  def load!(filename) do
    %__MODULE__{
      program: File.read!(filename)
        |> String.split(",")
        |> Enum.map(fn x ->
          x |> String.trim |> String.to_integer
        end)
        |> :array.from_list,
      ip: 0,
    }
  end

  def peek(intcode, address) do
    :array.get(address, intcode.program)
  end

  def poke(intcode, address, value) do
    %__MODULE__{ intcode | program: :array.set(address, value, intcode.program) }
  end

  def arg_value(intcode, opcode, arg_number)
  def arg_value(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 1 do
    :array.get(intcode.ip + 1, intcode.program)
  end
  def arg_value(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 0 do
    physical_location = :array.get(intcode.ip + 1, intcode.program)
    :array.get(physical_location, intcode.program)
  end
  def arg_value(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 1 do
    :array.get(intcode.ip + 2, intcode.program)
  end
  def arg_value(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 0 do
    physical_location = :array.get(intcode.ip + 2, intcode.program)
    :array.get(physical_location, intcode.program)
  end
  def arg_value(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 1 do
    :array.get(intcode.ip + 3, intcode.program)
  end
  def arg_value(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 0 do
    physical_location = :array.get(intcode.ip + 3, intcode.program)
    :array.get(physical_location, intcode.program)
  end

  def run(intcode) do
    opcode = :array.get(intcode.ip, intcode.program)
    case rem(opcode, 100) do

      1 ->
        %__MODULE__{
          program: :array.set(
            :array.get(intcode.ip + 3, intcode.program),
            arg_value(intcode, opcode, 1) + arg_value(intcode, opcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        }
        |> run

      2 ->
        %__MODULE__{
          program: :array.set(
            :array.get(intcode.ip + 3, intcode.program),
            arg_value(intcode, opcode, 1) * arg_value(intcode, opcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        }
        |> run

      3 ->
        %__MODULE__{
          program: :array.set(
            :array.get(intcode.ip + 1, intcode.program),
            IO.gets("> ") |> String.trim |> String.to_integer,
            intcode.program
          ),
          ip: intcode.ip + 2
        }
        |> run

      4 ->
        IO.puts(arg_value(intcode, opcode, 1))
        %__MODULE__{
          intcode | 
          ip: intcode.ip + 2
        }
        |> run

      99 ->
        intcode

    end
  end

  def answer_1a(filename \\ "input.txt") do
    load!(filename)
    |> run
    #5044655
  end
end
