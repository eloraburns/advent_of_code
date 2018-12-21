defmodule Cpu do
  use Bitwise, only_operators: true
  @ip_register 4

  def new() do
    {0, [0, 0, 0, 0, 0, 0]}
  end

  @compile {:inline, [put_ip: 2, get_next_ip: 1, load_instruction: 2]}
  defp put_ip(registers, ip), do: List.replace_at(registers, @ip_register, ip)
  defp get_next_ip(registers), do: Enum.at(registers, @ip_register) + 1

  def load_instruction({ip, _}, %{length: l} = program) when ip < l do
    :array.get(ip, program.code)
  end
  def load_instruction({_, [reg0 | _]}, _) do
    raise "segfault, register 0 contains #{reg0}"
  end

  def execute({:addr, s1, s2, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s1) + Enum.at(regs1, s2))
    {get_next_ip(regs2), regs2}
  end

  def execute({:addi, s, v, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s) + v)
    {get_next_ip(regs2), regs2}
  end

  def execute({:mulr, s1, s2, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s1) * Enum.at(regs1, s2))
    {get_next_ip(regs2), regs2}
  end

  def execute({:muli, s, v, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s) * v)
    {get_next_ip(regs2), regs2}
  end

  def execute({:banr, s1, s2, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s1) &&& Enum.at(regs1, s2))
    {get_next_ip(regs2), regs2}
  end

  def execute({:bani, s, v, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s) &&& v)
    {get_next_ip(regs2), regs2}
  end

  def execute({:borr, s1, s2, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s1) ||| Enum.at(regs1, s2))
    {get_next_ip(regs2), regs2}
  end

  def execute({:bori, s, v, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s) ||| v)
    {get_next_ip(regs2), regs2}
  end

  def execute({:setr, s, _, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, Enum.at(regs1, s))
    {get_next_ip(regs2), regs2}
  end

  def execute({:seti, v, _, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, v)
    {get_next_ip(regs2), regs2}
  end

  def execute({:gtir, v, s, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, (if v > Enum.at(regs1, s), do: 1, else: 0))
    {get_next_ip(regs2), regs2}
  end

  def execute({:gtri, s, v, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, (if Enum.at(regs1, s) > v, do: 1, else: 0))
    {get_next_ip(regs2), regs2}
  end

  def execute({:gtrr, s1, s2, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, (if Enum.at(regs1, s1) > Enum.at(regs1, s2), do: 1, else: 0))
    {get_next_ip(regs2), regs2}
  end

  def execute({:eqir, v, s, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, (if v == Enum.at(regs1, s), do: 1, else: 0))
    {get_next_ip(regs2), regs2}
  end

  def execute({:eqri, s, v, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, (if Enum.at(regs1, s) == v, do: 1, else: 0))
    {get_next_ip(regs2), regs2}
  end

  def execute({:eqrr, s1, s2, d}, {ip, regs0}) do
    regs1 = put_ip(regs0, ip)
    regs2 = List.replace_at(regs1, d, (if Enum.at(regs1, s1) == Enum.at(regs1, s2), do: 1, else: 0))
    {get_next_ip(regs2), regs2}
  end

end
