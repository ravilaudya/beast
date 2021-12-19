defmodule Beast.Polygon do
  use WebSockex
  require Logger
  require Beast.TickerAgent

  def get_tickers() do
    tickers = [
              %{symbol: "O:AAPL211223C00175000", stock: "AAPL", price: 0.0, beast_low: 0.44, beast_high: 0.59, target: [2.31, 2.54, 3.01, 3.58, 4.16]},
              %{symbol: "O:AAPL211223C00180000", stock: "AAPL", price: 0.0, beast_low: 0.26, beast_high: 0.37, target: [1.02, 1.17, 1.48, 1.86, 2.25]},
              %{symbol: "O:AAPL211223P00160000", stock: "AAPL", price: 0.0, beast_low: 0.11, beast_high: 0.18, target: [0.47, 0.51, 0.6, 0.71, 0.82]},
              %{symbol: "O:AAPL211223P00165000", stock: "AAPL", price: 0.0, beast_low: 0.22, beast_high: 0.33, target: [1.16, 1.24, 1.4, 1.6, 1.79]},

              %{symbol: "O:FB211223C00345000", stock: "FB", price: 0.0, beast_low: 0.48, beast_high: 0.68, target: [3.37, 3.76, 4.53, 5.48, 6.43]},
              %{symbol: "O:FB211223C00350000", stock: "FB", price: 0.0, beast_low: 0.39, beast_high: 0.51, target: [2.12, 2.4, 2.96, 3.65, 4.35]},
              %{symbol: "O:FB211223P00325000", stock: "FB", price: 0.0, beast_low: 0.47, beast_high: 0.74, target: [3.43, 3.78, 4.47, 5.33, 6.19]},
              %{symbol: "O:FB211223P00320000", stock: "FB", price: 0.0, beast_low: 0.35, beast_high: 0.60, target: [2.21, 2.46, 2.97, 3.59, 4.21]},

              %{symbol: "O:GOOGL211223C02950000", price: 0.0, stock: "GOOGL", beast_low: 2.96, beast_high: 4.4, target: [20.27, 22.87, 28.06, 34.48, 40.9]},
              %{symbol: "O:GOOGL211223P02850000", price: 0.0, stock: "GOOGL", beast_low: 4.81, beast_high: 6.39, target: [32.51, 38.6, 50.77, 65.82, 80.86]},


              %{symbol: "O:AMD211223C00140000", price: 0.0, stock: "AMD", beast_low: 0.58, beast_high: 0.82, target: [4.59, 5.01, 5.84, 6.87, 7.9]},
              %{symbol: "O:AMD211223C00150000", price: 0.0, stock: "AMD", beast_low: 0.24, beast_high: 0.39, target: [1.56, 1.76, 2.14, 2.62, 3.1]},
              %{symbol: "O:AMD211223P00130000", price: 0.0, stock: "AMD", beast_low: 0.25, beast_high: 0.36, target: [1.92, 2.03, 2.24, 2.51, 2.79]},
              %{symbol: "O:AMD211223P00133000", price: 0.0, stock: "AMD", beast_low: 0.30, beast_high: 0.45, target: [2.75, 2.95, 3.34, 3.83, 4.32]},


              %{symbol: "O:AMZN211217C03450000", price: 0.0, stock: "AMZN", beast_low: 4.52, beast_high: 7.33, target: [11.15, 14.32, 20.66, 28.5, 36.33]},
              %{symbol: "O:AMZN211217C03470000", price: 0.0, stock: "AMZN", beast_low: 3.32, beast_high: 5.72, target: [7.91, 10.45, 15.53, 21.81, 28.09]},

              %{symbol: "O:NVDA211223C00300000", price: 0.0, stock: "NVDA", beast_low: 1.10, beast_high: 1.63, target: [6.27, 7.18, 9, 11.25, 13.5]},
              %{symbol: "O:NVDA211223C00310000", price: 0.0, stock: "NVDA", beast_low: 0.69, beast_high: 1.13, target: [3.85, 4.45, 5.65, 7.13, 8.62]},
              %{symbol: "O:NVDA211223P00260000", price: 0.0, stock: "NVDA", beast_low: 0.40, beast_high: 0.54, target: [3.69, 4.08, 4.85, 5.8, 6.76]},
              %{symbol: "O:NVDA211223P00270000", price: 0.0, stock: "NVDA", beast_low: 0.68, beast_high: 0.87, target: [6.2, 6.77, 7.92, 9.34, 10.76]},

              %{symbol: "O:SNOW211223C00400000", price: 0.0, stock: "SNOW", beast_low: 0.46, beast_high: 0.78},
              %{symbol: "O:MSFT211223C00340000", price: 0.0, stock: "MSFT", beast_low: 0.30, beast_high: 0.49, target: [1.31, 1.73, 2.58, 3.63, 4.68]},
              %{symbol: "O:MSFT211223P00310000", price: 0.0, stock: "MSFT", beast_low: 0.13, beast_high: 0.20, target: [1.62, 1.74, 1.98, 2.28, 2.58]},
              %{symbol: "O:MSFT211223P00315000", price: 0.0, stock: "MSFT", beast_low: 0.20, beast_high: 0.29, target: [2.45, 2.61, 2.94, 3.35, 3.75]},
            ]
    Beast.TickerAgent.tickers()
  end


  def get_tickers_text() do
    tickers = get_tickers()
    Enum.reduce tickers, "", fn x, acc ->
      "AM.#{x.symbol},#{acc}"
    end
  end

  def find_ticker(sym) do
    tickers = get_tickers()
    Enum.find(tickers, fn ticker -> Map.get(ticker, :symbol) == sym end)
  end

  defp broadcast(msg) do
    Logger.info("**** BROADCASTING option: #{inspect msg}")
    Phoenix.PubSub.broadcast(Beast.PubSub, "options", msg)
  end

  def handle_ticker_update(event) do
    Logger.info("Handling ticker update: #{inspect event}")
    sym = Map.get(event, "sym")
    _volume = Map.get(event, "v")
    _acc_volume = Map.get(event, "av")
    _open = Map.get(event, "op")
    _vol_wt_avg_price = Map.get(event, "vw")
    _window_open = Map.get(event, "o")
    window_close = Map.get(event, "c")
    _window_high = Map.get(event, "h")
    _window_low = Map.get(event, "l")
    _today_vol_wt_avg_price = Map.get(event, "a")
    _window_avg_trade_size = Map.get(event, "z")
    _start_timestamp = Map.get(event, "s")
    _end_timestamp = Map.get(event, "e")

    ticker = find_ticker(sym)
    Logger.warn("FOUND TICKER: #{inspect ticker}")

    only_beast_matches = true

    if only_beast_matches == true do
      if window_close <= Map.get(ticker, :beast_high) do
          broadcast({:update, %{ticker | price: window_close}})
      end
    else
      broadcast({:update, %{ticker | price: window_close}})
    end
  end

  def handle_status_update(_event) do
    # nothing
  end


  def parse_events(events) do
    Enum.map(events, fn event ->
      type = Map.get(event, "ev")
      case type do
        "status" -> handle_status_update(event)
        "AM" -> handle_ticker_update(event)
        "A" -> handle_ticker_update(event)
        _ -> Logger.error("Unknown event type: #{event}")
      end
    Process.sleep(1000)
    handle_frame({:text, "hello"}, ['awesome elixir'])
    end)
  end

  def start_link(state) do
    {:ok, pid}  = WebSockex.start_link("wss://socket.polygon.io/options", __MODULE__, state)
    Logger.warn("Started POLYGON CLIENT...#{inspect pid}")
    {:ok, pid}
  end

  def handle_frame({:text, "[{\"ev\":\"status\",\"status\":\"connected\",\"message\":\"Connected Successfully\"}]" = msg}, state) do
    Logger.info("Received Message: #{msg}")
    {:reply, {:text, Poison.encode!(%{action: "auth", params: "X5ndpVseKPBdJ6MbIyiaB1tvqJBmcHSe"})}, state}
  end

  def handle_frame({:text, "[{\"ev\":\"status\",\"status\":\"auth_success\",\"message\":\"authenticated\"}]" = msg}, state) do
    Logger.info("Received Message: #{msg}")
    tickers = get_tickers()
    Logger.info("GOT TICKERS: #{inspect tickers}")
    broadcast({:init, tickers})
    tickers_text = get_tickers_text()
    # Logger.info("Subscribing for tickers: #{tickers}")
    {:reply, {:text, Poison.encode!(%{action: "subscribe", params: tickers_text})}, state}
  end

  def handle_frame({:text, msg}, state) do
    Logger.info("Received Message: #{msg}")
    # json_msg = Poison.decode!(msg)
    # parse_events(json_msg)
    parse_events(generate_test_event())
    {:ok, state}
  end

  def handle_frame(any, state) do
    Logger.warn("Ignoring unknown frame - #{inspect(any)}")
    {:ok, state}
  end


  def generate_test_event() do
    ticker = Enum.random(get_tickers())
    [%{"ev" => "AM", "sym" => Map.get(ticker, :symbol), "c" => Enum.random(10..200) / 100}]
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  def subscribe do
    Logger.info("***** SUBSCRIBING ******")
    Phoenix.PubSub.subscribe(Beast.PubSub, "options")
  end

end
