defmodule Fun do
  def run do
    File.stream!("input.txt")
    |> Enum.map(fn t ->
      t
      |> String.trim
      |> String.to_integer
      |> fuel_for(0)
    end)
    |> Enum.reduce(0, &Kernel.+/2)
    |> IO.puts
  end

  def fuel_for(x, fuel_acc) do
    case div(x, 3) - 2 do
      fuel when fuel > 0 -> fuel_for(fuel, fuel_acc + fuel)
      _ -> fuel_acc
    end
  end
end
