defmodule Intcode do
  defstruct [:program, :ip, :input, :output]

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
          intcode |
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
          intcode |
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
          intcode |
          program: :array.set(
            :array.get(intcode.ip + 1, intcode.program),
            intcode.input |> hd,
            intcode.program
          ),
          input: intcode.input |> tl,
          ip: intcode.ip + 2
        }
        |> run

      4 ->
        %__MODULE__{
          intcode | 
          output: [arg_value(intcode, opcode, 1) | intcode.output],
          ip: intcode.ip + 2
        }
        |> run

      5 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) != 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run

      6 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) == 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run

      7 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            :array.get(intcode.ip + 3, intcode.program),
            if arg_value(intcode, opcode, 1) < arg_value(intcode, opcode, 2) do 1 else 0 end,
            intcode.program
          ),
          ip: intcode.ip + 4
        }
        |> run

      8 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            :array.get(intcode.ip + 3, intcode.program),
            if arg_value(intcode, opcode, 1) == arg_value(intcode, opcode, 2) do 1 else 0 end,
            intcode.program
          ),
          ip: intcode.ip + 4
        }
        |> run

      99 ->
        intcode

    end
  end

  def run_with_phases(phases, intcode) do
    Enum.reduce(phases, 0, fn phase, input ->
      %__MODULE__{intcode | input: [phase, input]}
      |> run
      |> (fn ic -> ic.output |> hd end).()
    end)
  end

  def permutations([]), do: []
  def permutations([x]), do: [[x]]
  def permutations(l) do
    for h <- l,
        t <- permutations(Enum.reject(l, &(&1 == h)))
    do
      [h | t]
    end
  end

  def answer_1a(filename \\ "input.txt") do
    program = load!(filename)
    permutations([0,1,2,3,4])
    |> Enum.map(fn phases ->
      {run_with_phases(phases, program), phases}
    end)
    |> Enum.max
    # {567045, [0, 2, 4, 3, 1]}
  end
end
