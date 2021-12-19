defmodule Beast.TickerAgent do
  use Agent
  require Logger

  def start_link(initial_value) do
    # tickers = [
    #   %{symbol: "O:AAPL211223C00175000", stock: "AAPL", price: 0.0, beast_low: 0.44, beast_high: 0.59, target: [2.31, 2.54, 3.01, 3.58, 4.16]},
    #   %{symbol: "O:AAPL211223C00180000", stock: "AAPL", price: 0.0, beast_low: 0.26, beast_high: 0.37, target: [1.02, 1.17, 1.48, 1.86, 2.25]},
    # ]
    {:ok, contents} = File.read("./options-res.txt")
    split_contents = String.split(contents, "\n")
    tickers = Enum.map(split_contents, fn line ->
      list = String.split(line)
      %{symbol: Enum.at(list, 0), price: 0.0, beast_low: Enum.at(list, 3), beast_high: Enum.at(list, 5)}
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
