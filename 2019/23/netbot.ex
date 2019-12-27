defmodule Netbot do
  require Intcode

  defmodule Machine do
    use GenServer

    def start_link(network_address) do
      GenServer.start_link(__MODULE__, [network_address], name: :"mac_#{network_address}")
    end

    def init([network_address]) do
      code = %Intcode{ Intcode.load!("input.txt") | input: network_address }
      {:ok, {code, :queue.new}}
    end

    def handle_cast({:input, x, y}, {code, input_queue}) do
      nq = :queue.in(y, :queue.in(x, input_queue))
      {:noreply, {code, nq}, 0}
    end

    def handle_cast(:start, state), do: {:noreply, state, 0}

    def handle_info(:timeout, {code, input_queue}) do
      case Intcode.run(code) do
        {:need_input, newcode} ->
          case :queue.out(input_queue) do
            {:empty, _} -> 
              Process.sleep(10)
              {:noreply, {%Intcode{ newcode | input: -1 }, input_queue}, 0}
            {{:value, input}, newqueue} ->
              {:noreply, {%Intcode{ newcode | input: input }, newqueue}, 0}
          end
        {:made_output, %{output: outmac} = newcode} ->
          {:made_output, %{output: outx} = newcode} = Intcode.run(newcode)
          {:made_output, %{output: outy} = newcode} = Intcode.run(newcode)
          GenServer.cast(:"mac_#{outmac}", {:input, outx, outy})
          {:noreply, {newcode, input_queue}, 0}
        {:halt, newcode} ->
          {:stop, :normal, {newcode, input_queue}}
      end
    end
  end

  def solve_1a do
    Process.register(self(), :mac_255)

    0..49
    |> Enum.map(&Machine.start_link(&1))
    |> Enum.each(fn {:ok, pid} -> GenServer.cast(pid, :start) end)

    receive do
      {:input, _, y} ->
        IO.puts(y)
        Process.exit(self(), :done)
      other -> IO.inspect(other)
    end
  end

end
