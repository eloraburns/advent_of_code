defmodule Compiler do
  def load(sourcefilename) do
    File.stream!(sourcefilename)
    |> Enum.map(&Regex.run(
      ~r/^(#ip (?<ip>\d)|(?<instruction>\w\w\w\w) (?<a1>\d+) (?<a2>\d+) (?<a3>\d+))\n$/,
      &1,
      capture: ["ip", "instruction", "a1", "a2", "a3"]
    ))
    |> Enum.reduce(%Program{}, fn
     ["4" = ip, "", "", "", ""], p -> %Program{ p | ip: ip |> String.to_integer }
     ["", inst, a1, a2, a3], p -> %Program{ p |
       length: p.length + 1,
       code: :array.set(
         p.length,
         {
           inst |> String.to_atom,
           a1 |> String.to_integer,
           a2 |> String.to_integer,
           a3 |> String.to_integer
         },
         p.code
       )
     }
    end)
  end
end
