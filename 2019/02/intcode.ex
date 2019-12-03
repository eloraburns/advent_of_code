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

  def arg_value(intcode, arg_number) do
    physical_location = :array.get(intcode.ip + arg_number, intcode.program)
    :array.get(physical_location, intcode.program)
  end

  def run(intcode) do
    case :array.get(intcode.ip, intcode.program) do

      1 ->
        run(%__MODULE__{
          program: :array.set(
            :array.get(intcode.ip + 3, intcode.program),
            arg_value(intcode, 1) + arg_value(intcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        })

      2 ->
        run(%__MODULE__{
          program: :array.set(
            :array.get(intcode.ip + 3, intcode.program),
            arg_value(intcode, 1) * arg_value(intcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        })

      99 ->
        intcode

    end
  end

  def answer_1a do
    load!("input.txt")
    |> poke(1, 12)
    |> poke(2, 2)
    |> run
    |> peek(0)
  end

  def answer_1b do
    p = load!("input.txt")
    for noun <- 0..99, verb <- 0..99 do
      {noun, verb}
    end
    |> Stream.map(fn {n, v} ->
      {
        n,
        v,
        (p |> poke(1, n) |> poke(2, v) |> run() |> peek(0))
      }
    end)
    |> Stream.drop_while(fn {_, _, output} -> output != 19690720 end)
    |> Stream.take(1)
    |> Enum.to_list
  end
end
