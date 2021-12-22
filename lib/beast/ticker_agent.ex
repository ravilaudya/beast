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


  def generate_symbol(nil), do: %{}
  def generate_symbol(""), do: %{}
  def generate_symbol(sym) do
    all_parts = split_symbol(sym)
    strike = generate_strike(Map.get(all_parts, :strike))
    stock = all_parts.ticker
    option_sym = "O:#{Map.get(all_parts, :ticker)}#{Map.get(all_parts, :date)}#{Map.get(all_parts, :type)}#{strike}"
    %{stock: stock, option_symbol: option_sym, option_type: all_parts.type}
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

  defp fetch_option_detail(ticker) do
    Logger.info("**** FETCHING OPTION DETAILS FOR : #{ticker.stock}, #{ticker.symbol}")
    url = "https://api.polygon.io/v3/snapshot/options/#{ticker.stock}/#{ticker.symbol}?apiKey=X5ndpVseKPBdJ6MbIyiaB1tvqJBmcHSe"
    response = HTTPoison.get!(url)
    resp = Poison.decode!(response.body)
    # Logger.info("***** GOT RESPONSE: #{inspect resp}")
    %{ticker | price: Map.get(resp, "results")
                      |> Map.get("day")
                      |> Map.get("close"),
               open: Map.get(resp, "results")
                     |> Map.get("day")
                     |> Map.get("open"),
               vwap: Map.get(resp, "results")
                     |> Map.get("day")
                     |> Map.get("vwap"),
               volume: Map.get(resp, "results")
                     |> Map.get("day")
                     |> Map.get("volume"),
               open_interest: Map.get(resp, "results")
                              |> Map.get("open_interest")}
  end

  def start_link(_initial_value) do
    {:ok, contents} = File.read("./options-res.txt")
    split_contents = String.split(contents, "\n")
    tickers = Enum.map(split_contents, fn line ->
      list = String.split(line)
      option_detail = generate_symbol(Enum.at(list, 0))
      targets = generate_targets(list)
      %{symbol: option_detail.option_symbol,
        stock: option_detail.stock,
        readable_symbol: Enum.at(list, 0),
        price: 0.0,
        open: 0.0,
        vwap: 0.0,
        type: option_detail.option_type,
        open_interest: 0,
        volume: 0,
        last_alerted_at: nil,
        beast_low: safe_parse_float(Enum.at(list, 3)),
        beast_high: safe_parse_float(Enum.at(list, 5)),
        targets: targets}
    end)
    tickers = Enum.map tickers, fn ticker ->
      fetch_option_detail(ticker)
    end
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
          ticker
        else
          x
        end
      end)
    end)
  end

end
