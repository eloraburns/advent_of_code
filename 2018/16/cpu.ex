defmodule Cpu do
  use Bitwise, only_operators: true

  def new() do
    [0, 0, 0, 0]
  end

  def instructions(), do: ~w(
    addr addi mulr muli banr bani borr bori
    setr seti gtir gtri gtrr eqir eqri eqrr
  )a

  def execute({:addr, s1, s2, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s1) + Enum.at(regs1, s2))
  end

  def execute({:addi, s, v, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s) + v)
  end

  def execute({:mulr, s1, s2, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s1) * Enum.at(regs1, s2))
  end

  def execute({:muli, s, v, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s) * v)
  end

  def execute({:banr, s1, s2, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s1) &&& Enum.at(regs1, s2))
  end

  def execute({:bani, s, v, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s) &&& v)
  end

  def execute({:borr, s1, s2, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s1) ||| Enum.at(regs1, s2))
  end

  def execute({:bori, s, v, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s) ||| v)
  end

  def execute({:setr, s, _, d}, regs1) do
    List.replace_at(regs1, d, Enum.at(regs1, s))
  end

  def execute({:seti, v, _, d}, regs1) do
    List.replace_at(regs1, d, v)
  end

  def execute({:gtir, v, s, d}, regs1) do
    List.replace_at(regs1, d, (if v > Enum.at(regs1, s), do: 1, else: 0))
  end

  def execute({:gtri, s, v, d}, regs1) do
    List.replace_at(regs1, d, (if Enum.at(regs1, s) > v, do: 1, else: 0))
  end

  def execute({:gtrr, s1, s2, d}, regs1) do
    List.replace_at(regs1, d, (if Enum.at(regs1, s1) > Enum.at(regs1, s2), do: 1, else: 0))
  end

  def execute({:eqir, v, s, d}, regs1) do
    List.replace_at(regs1, d, (if v == Enum.at(regs1, s), do: 1, else: 0))
  end

  def execute({:eqri, s, v, d}, regs1) do
    List.replace_at(regs1, d, (if Enum.at(regs1, s) == v, do: 1, else: 0))
  end

  def execute({:eqrr, s1, s2, d}, regs1) do
    List.replace_at(regs1, d, (if Enum.at(regs1, s1) == Enum.at(regs1, s2), do: 1, else: 0))
  end

end
