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
    initial_val = %{ticker: "", date: "", type: "", strike: "", state: "start"}
    Enum.reduce(all_chars, initial_val, fn c, acc ->
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


  def generate_symbol(nil), do: {"", ""}
  def generate_symbol(""), do: {"", ""}
  def generate_symbol(sym) do
    all_parts = split_symbol(sym)
    strike = generate_strike(Map.get(all_parts, :strike))
    option_sym = "O:#{Map.get(all_parts, :ticker)}#{Map.get(all_parts, :date)}#{Map.get(all_parts, :type)}#{strike}"
    readable_sym = Enum.join([all_parts.ticker, all_parts.date, "#{all_parts.strike}#{all_parts.type}"], " ")
    {option_sym, readable_sym}
  end

  defp safe_parse_float(s) do
    case Float.parse(s) do
      {num, _} -> num
      :error -> 0.0
    end
  end

  defp generate_targets(list) do
    list
    |> Enum.slice(9, 5)
    |> Enum.map(fn x -> safe_parse_float(x) end)
    |> Enum.join(", ")
  end

  def start_link(_initial_value) do
    {:ok, contents} = File.read("./options-res.txt")
    split_contents = String.split(contents, "\n")
    tickers = Enum.map(split_contents, fn line ->
      list = String.split(line)
      {symbol, readable_symbol} = generate_symbol(Enum.at(list, 0))
      targets = generate_targets(list)
      %{symbol: symbol,
        readable_symbol: readable_symbol,
        price: 0.0,
        beast_low: safe_parse_float(Enum.at(list, 3)),
        beast_high: safe_parse_float(Enum.at(list, 5)),
        targets: targets}
    end)
    Logger.warn("STARTING TICKERS...#{inspect tickers}")
    Agent.start_link(fn -> tickers end, name: __MODULE__)
  end

  def tickers() do
    Agent.get(__MODULE__, fn tickers -> tickers end)
  end

  def update(ticker) do
    Agent.update(__MODULE__, fn tickers ->
      Enum.map(tickers, fn x ->
        if ticker.symbol == x.symbol do
          %{x | price: ticker.price}
        else
          x
        end
      end)
    end)
  end

end
