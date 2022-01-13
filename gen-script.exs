require Logger

defmodule OptionReader do
  defp safe_parse_float(s) do
    case Float.parse(s) do
      {num, _} -> num
      :error -> 0.0
    end
  end

  def get_tickers() do
    {:ok, contents} = File.read("./options-res.txt")
    split_contents = String.split(contents, "\n")
    tickers = Enum.map(split_contents, fn line ->
      list = String.split(line)
      beast_low = safe_parse_float(Enum.at(list, 3))
      beast_high = safe_parse_float(Enum.at(list, 5))
      %{symbol: Enum.at(list, 0), beast_low: beast_low, beast_high: beast_high}
    end)
  end
end

tickers = OptionReader.get_tickers()
tickers = Enum.map tickers, fn ticker ->
  IO.puts("else if(GetSymbol() == \"#{ticker.symbol}\") then #{inspect ticker.beast_high}")
end
