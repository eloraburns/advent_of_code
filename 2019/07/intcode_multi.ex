defmodule Intcode do
  defstruct [:name, :program, :ip, :last_output, :wired_to, :report_to]

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
            receive do
              {:input, x} -> x
            end,
            intcode.program
          ),
          ip: intcode.ip + 2
        }
        |> run

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
        if intcode.report_to do
          send intcode.report_to, {:result, intcode.last_output}
        end
    end
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

  def answer_1b(filename \\ "input.txt") do
    program = load!(filename)
    permutations([5,6,7,8,9])
    |> Enum.map(fn [phasea, phaseb, phasec, phased, phasee] = phases ->
      IO.inspect phases
      runner_pid = self()
      a = spawn(fn -> run(%__MODULE__{program | name: :a, wired_to: :amp_b}) end)
      b = spawn(fn -> run(%__MODULE__{program | name: :a, wired_to: :amp_c}) end)
      c = spawn(fn -> run(%__MODULE__{program | name: :a, wired_to: :amp_d}) end)
      d = spawn(fn -> run(%__MODULE__{program | name: :a, wired_to: :amp_e}) end)
      e = spawn(fn -> run(%__MODULE__{program | name: :a, wired_to: :amp_a, report_to: runner_pid}) end)
      Process.register(a, :amp_a)
      Process.register(b, :amp_b)
      Process.register(c, :amp_c)
      Process.register(d, :amp_d)
      Process.register(e, :amp_e)
      send a, {:input, phasea}
      send b, {:input, phaseb}
      send c, {:input, phasec}
      send d, {:input, phased}
      send e, {:input, phasee}

      send a, {:input, 0}
      receive do
        {:result, x} -> {x, phases}
      end
    end)
    |> Enum.max
  end
end
