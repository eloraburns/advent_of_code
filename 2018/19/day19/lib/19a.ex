defmodule Nineteen do
  def run(cpu, program) do
    Stream.iterate(cpu, fn c ->
      c
      |> Cpu.load_instruction(program)
      |> Cpu.execute(c)
    end)
    |> Stream.run
  end

  def solve do
    cpu = Cpu.new
    program = Compiler.load("input.txt")
    run(cpu, program)
  end
end
