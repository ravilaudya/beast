defmodule Beast.TickerAgent do
  use Agent
  require Logger


  defp generate_strike(strike) do
    strike = "#{strike}0"
    case String.length(strike) do
      2 -> "000#{strike}000"
      3 -> "000#{strike}00"
      4 -> "00#{strike}00"
      5 -> "0#{strike}00"
      6 -> "#{strike}00"
    end
  end

  defp split_symbol(sym) do
    all_chars = Regex.split(~r{}, sym)
    result = %{ticker: "", date: "", type: "", strike: "", state: "start"}
    result = Enum.reduce(all_chars, result, fn c, acc ->
      cond do
        String.match?(c, ~r/^[[:alpha:]]+$/) == true ->
          case Map.get(acc, :state) do
            "start" -> %{acc | ticker: "#{Map.get(acc, :ticker)}#{c}", state: "symbol"}
            "symbol" -> %{acc | ticker: "#{Map.get(acc, :ticker)}#{c}"}
            "date" ->  %{acc | type: "#{c}", state: "type"}
            "type" -> %{acc | type: "#{c}", state: "type"}
            _ -> acc
          end
        String.match?(c, ~r/^[[:digit:]]+$/) == true ->
          case Map.get(acc, :state) do
            "symbol" -> %{acc | date: "#{Map.get(acc, :date)}#{c}", state: "date"}
            "date" -> %{acc | date: "#{Map.get(acc, :date)}#{c}"}
            "type" -> %{acc | strike: "#{Map.get(acc, :strike)}#{c}", state: "strike"}
            "strike" -> %{acc | strike: "#{Map.get(acc, :strike)}#{c}"}
            _ -> acc
          end
        true -> acc
      end
    end)
  end


  def generate_symbol(nil), do: ""
  def generate_symbol(""), do: ""
  def generate_symbol(sym) do
    all_parts = split_symbol(sym)
    strike = generate_strike(Map.get(all_parts, :strike))
    "O:#{Map.get(all_parts, :ticker)}#{Map.get(all_parts, :date)}#{Map.get(all_parts, :type)}#{strike}"
  end

  def start_link(initial_value) do
    {:ok, contents} = File.read("./options-res.txt")
    split_contents = String.split(contents, "\n")
    tickers = Enum.map(split_contents, fn line ->
      list = String.split(line)
      symbol = generate_symbol(Enum.at(list, 0))
      %{symbol: symbol, price: 0.0, beast_low: Enum.at(list, 3), beast_high: Enum.at(list, 5)}
    end)
    Logger.warn("STARTING TICKERS...#{inspect tickers}")
    Agent.start_link(fn -> tickers end, name: __MODULE__)
  end

  def tickers() do
    Agent.get(__MODULE__, fn tickers -> tickers end)
  end

  def update() do
    Agent.update(__MODULE__, fn tickers -> tickers end)
  end
end
