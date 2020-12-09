defmodule Vm do
  defstruct [
    code: :array.new,
    code_size: 0,
    pc: nil,
    acc: 0
  ]

  defmodule Opcode do
    defstruct [
      op: nil,
      arg: 0
    ]

    def parse(<< op::binary-size(3), " ", arg_s::binary >>) do
      {arg, _} = Integer.parse(arg_s)
      %__MODULE__{op: op |> String.to_atom, arg: arg}
    end
  end

  def load_vm(filename) do
    code = :array.from_list(
      filename
      |> File.stream!
      |> Enum.map(&Opcode.parse/1)
    )
    %__MODULE__{
      code: code,
      code_size: :array.size(code),
      pc: 0
    }
  end

  def step(vm) do
    case :array.get(vm.pc, vm.code) do
      %{op: :acc, arg: n} ->
        %__MODULE__{ vm |
          pc: vm.pc + 1,
          acc: vm.acc + n
        }
      %{op: :jmp, arg: n} ->
        %__MODULE__{ vm |
          pc: vm.pc + n
        }
      %{op: :nop} ->
        %__MODULE__{ vm |
          pc: vm.pc + 1
        }
    end
  end

  def run_to_dupe(vm, seen \\ MapSet.new) do
    case vm.pc in seen do
      true -> {vm, seen}
      false -> run_to_dupe(step(vm), MapSet.put(seen, vm.pc))
    end
  end

  def solve8a(filename \\ "input.txt") do
    vm = load_vm(filename)
    {vm, _seen} = run_to_dupe(vm)
    vm.acc
  end

  def patch(vm, pc, opcode) when opcode in ~w(nop jmp)a do
    patchy = :array.get(pc, vm.code)
    IO.puts("Patching #{pc}:#{inspect patchy} to #{opcode}")
    if patchy.op not in ~w(nop jmp)a do
      raise "Patch not allowed!"
    end
    %__MODULE__{ vm |
      code: :array.set(pc, %Opcode{ patchy | op: opcode }, vm.code)
    }
  end

  def patch_each(vm, from_op, to_op) do
    vm.code |> :array.to_list |> Enum.with_index |> Enum.flat_map(fn
      {%Opcode{op: ^from_op} = op, pc} ->
        [[pc, to_op]]
      _ -> []
    end)
  end

  def run_to_end(vm, seen \\ MapSet.new)
  def run_to_end(vm, seen) when vm.pc == vm.code_size, do: {:ok, vm, seen}
  def run_to_end(vm, seen) do
    case vm.pc in seen do
      true -> {:loop_detected, vm, seen}
      false -> run_to_end(step(vm), MapSet.put(seen, vm.pc))
    end
  end

  def what_jumps_to(target_pc, vm) do
    0..(vm.code_size - 1)
    |> Enum.flat_map(fn pc ->
      case :array.get(pc, vm.code) do
        %{op: _, arg: n} = op when pc + n == target_pc -> [{pc, op}]
        _ -> []
      end
    end)
  end

  def test8b do
    vm = load_vm("test.txt")
    |> patch(7, :nop)

    {:ok, vm, _seen} = run_to_end(vm)
    vm.acc
  end

  def solve8b(filename \\ "input.txt") do
    vm = load_vm(filename)
    #|> patch(575, :jmp) # result: 527 is too low (also disallowed)
    #|> patch(617, :nop)

    (patch_each(vm, :jmp, :nop) ++ patch_each(vm, :nop, :jmp))
    |> Enum.flat_map(fn p ->
      apply(__MODULE__, :patch, [vm | p])
      |> run_to_end
      |> case do
        {:ok, vm, _seen} -> [p, vm.acc]
        _ -> []
      end
    end)

    # 527 is too low
  end
end
