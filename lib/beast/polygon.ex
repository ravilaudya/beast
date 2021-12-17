defmodule Beast.Polygon do
  use WebSockex
  require Logger

  def get_tickers() do
    tickers = [
              %{ticker: "AM.AAPL211217C00175000", stock: "AAPL", beast_bottom: 0.48, beast_top: 0.63, target: [1.08, 1.38, 1.97, 2.7, 3.44]},
              %{ticker: "AM.AAPL211217P00165000", stock: "AAPL", beast_bottom: 0.10, beast_top: 0.21, target: [0.33, 0.37, 0.45, 0.55, 0.65]},
              %{ticker: "AM.AAPL211223C00175000", stock: "AAPL", beast_bottom: 0.47, beast_top: 0.62, target: [3.25, 3.54, 4.11, 4.82, 5.52]},
              %{ticker: "AM.AAPL211223C00180000", stock: "AAPL", beast_bottom: 0.30, beast_top: 0.39, target: [1.71, 1.92, 2.36, 2.89, 3.43]},
              %{ticker: "AM.AAPL211223P00160000", stock: "AAPL", beast_bottom: 0.09, beast_top: 0.17, target: [0.75, 0.8, 0.89, 1, 1.1]},
              %{ticker: "AM.AAPL211223P00165000", stock: "AAPL", beast_bottom: 0.19, beast_top: 0.30, target: [1.63, 1.7, 1.86, 2.06, 2.26]},

              %{ticker: "AM.FB211217C00340000", stock: "FB", beast_bottom: 0.68, beast_top: 0.88, target: [1.87, 2.32, 3.21, 4.32, 5.43]},
              %{ticker: "AM.FB211217C00342500", stock: "FB", beast_bottom: 0.51, beast_top: 0.67, target: [1.23, 1.61, 2.36, 3.3, 4.23]},
              %{ticker: "AM.FB211217P00327500", stock: "FB", beast_bottom: 0.46, beast_top: 0.78, target: [1.22, 1.6, 2.37, 3.32, 4.27]},
              %{ticker: "AM.FB211223C00345000", stock: "FB", beast_bottom: 0.55, beast_top: 0.71, target: [3.37, 3.76, 4.53, 5.48, 6.43]},
              %{ticker: "AM.FB211223C00350000", stock: "FB", beast_bottom: 0.39, beast_top: 0.51, target: [2.12, 2.4, 2.96, 3.65, 4.35]},
              %{ticker: "AM.FB211223P00325000", stock: "FB", beast_bottom: 0.47, beast_top: 0.74, target: [3.43, 3.78, 4.47, 5.33, 6.19]},
              %{ticker: "AM.FB211223P00320000", stock: "FB", beast_bottom: 0.35, beast_top: 0.60, target: [2.21, 2.46, 2.97, 3.59, 4.21]},

              %{ticker: "AM.GOOGL211223C02950000", stock: "GOOGL", beast_bottom: 2.96, beast_top: 4.4, target: [20.27, 22.87, 28.06, 34.48, 40.9]},
              %{ticker: "AM.GOOGL211217P02850000", stock: "GOOGL", beast_bottom: 2.85, beast_top: 4.37, target: [11.53, 15.32, 22.89, 32.25, 41.61]},
              %{ticker: "AM.GOOGL211217C02920000", stock: "GOOGL", beast_bottom: 3.14, beast_top: 4.81, target: [9.26, 12.06, 17.65, 24.56, 31.47]},
              %{ticker: "AM.GOOGL211217C02930000", stock: "GOOGL", beast_bottom: 2.7, beast_top: 4.01, target: [6.84, 9.29, 14.17, 20.21, 26.26]},
              %{ticker: "AM.GOOGL211223P02850000", stock: "GOOGL", beast_bottom: 4.81, beast_top: 6.39, target: [32.51, 38.6, 50.77, 65.82, 80.86]},


              %{ticker: "AM.AMD211217C00140000", stock: "AMD", beast_bottom: 0.58, beast_top: 0.83, target: [2.03, 2.49, 3.39, 4.52, 5.64]},
              %{ticker: "AM.AMD211217C00142000", stock: "AMD", beast_bottom: 0.42, beast_top: 0.56, target: [1.35, 1.73, 2.5, 3.45, 4.4]},
              %{ticker: "AM.AMD211217P00135000", stock: "AMD", beast_bottom: 0.38, beast_top: 0.55, target: [1.13, 1.3, 1.64, 2.07, 2.5]},
              %{ticker: "AM.AMD211223C00140000", stock: "AMD", beast_bottom: 0.58, beast_top: 0.82, target: [4.59, 5.01, 5.84, 6.87, 7.9]},
              %{ticker: "AM.AMD211223C00150000", stock: "AMD", beast_bottom: 0.24, beast_top: 0.39, target: [1.56, 1.76, 2.14, 2.62, 3.1]},
              %{ticker: "AM.AMD211223P00130000", stock: "AMD", beast_bottom: 0.25, beast_top: 0.36, target: [1.92, 2.03, 2.24, 2.51, 2.79]},
              %{ticker: "AM.AMD211223P00133000", stock: "AMD", beast_bottom: 0.30, beast_top: 0.45, target: [2.75, 2.95, 3.34, 3.83, 4.32]},


              %{ticker: "AM.AMZN211217C03450000", stock: "AMZN", beast_bottom: 4.52, beast_top: 7.33, target: [11.15, 14.32, 20.66, 28.5, 36.33]},
              %{ticker: "AM.AMZN211217C03470000", stock: "AMZN", beast_bottom: 3.32, beast_top: 5.72, target: [7.91, 10.45, 15.53, 21.81, 28.09]},

              %{ticker: "AM.NVDA211217C00290000", stock: "NVDA", beast_bottom: 1.48, beast_top: 2.13, target: [4.45, 5.82, 8.57, 11.97, 15.36]},
              %{ticker: "AM.NVDA211217C00295000", stock: "NVDA", beast_bottom: 1.17, beast_top: 1.77, target: [2.93, 4.07, 6.34, 9.15, 11.97]},
              %{ticker: "AM.NVDA211217P00270000", stock: "NVDA", beast_bottom: 0.45, beast_top: 0.62, target: [1.71, 2.21, 3.2, 4.43, 5.65]},
              %{ticker: "AM.NVDA211223C00300000", stock: "NVDA", beast_bottom: 1.10, beast_top: 1.63, target: [6.27, 7.18, 9, 11.25, 13.5]},
              %{ticker: "AM.NVDA211223C00310000", stock: "NVDA", beast_bottom: 0.69, beast_top: 1.13, target: [3.85, 4.45, 5.65, 7.13, 8.62]},
              %{ticker: "AM.NVDA211223P00260000", stock: "NVDA", beast_bottom: 0.40, beast_top: 0.54, target: [3.69, 4.08, 4.85, 5.8, 6.76]},
              %{ticker: "AM.NVDA211223P00270000", stock: "NVDA", beast_bottom: 0.68, beast_top: 0.87, target: [6.2, 6.77, 7.92, 9.34, 10.76]},

              %{ticker: "AM.SNOW211223C00400000", stock: "SNOW", beast_bottom: 0.46, beast_top: 0.78}]
    tickers
  end

  def get_tickers_text() do
    tickers = get_tickers()
    Enum.reduce tickers, "", fn x, acc ->
      "#{x.ticker},#{acc}"
    end
  end

  def find_ticker(sym) do
    tickers = get_tickers()
    Enum.find(tickers, fn ticker -> Map.get(ticker, :ticker) == sym end)
  end

  def handle_ticker_update(event) do
    Logger.info("Handling ticker update: #{inspect event}")
    Process.sleep(1000)
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
      if window_close <= Map.get(ticker, :beast_top) do
        BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
          sym: sym,
          price: window_close,
          beast_low: Map.get(ticker, :beast_bottom),
          beast_high: Map.get(ticker, :beast_top),
          target: Map.get(ticker, :target)
        }
      end
    else
      BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
        sym: sym,
        price: window_close,
        beast_low: Map.get(ticker, :beast_bottom),
        beast_high: Map.get(ticker, :beast_top),
        target: Map.get(ticker, :target)
      }
    end
  end

  def handle_status_update(_event) do
    Process.sleep(1000)
    BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
      sym: "test",
      price: 1.5,
      beast_low: 1.0,
      beast_high: 2.0
    }
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
    tickers = get_tickers_text()
    # Logger.info("Subscribing for tickers: #{tickers}")
    {:reply, {:text, Poison.encode!(%{action: "subscribe", params: tickers})}, state}
  end

  def handle_frame({:text, msg}, state) do
    Logger.info("Received Message: #{msg}")
    json_msg = Poison.decode!(msg)
    # Logger.info("Decoded message: #{inspect json_msg}")
    #parse_events(json_msg)
    json_msg = [%{"ev" => "AM", "sym" => "AM.NVDA211223P00270000", "c" => 0.70},
                %{"ev" => "AM", "sym" => "AM.AMD211223P00133000", "c" => 0.4},
                %{"ev" => "AM", "sym" => "AM.NVDA211217P00270000", "c" =>5.70}
               ]
    parse_events(json_msg)
    {:ok, state}
  end

  def handle_frame(any, state) do
    Logger.warn("Ignoring unknown frame - #{inspect(any)}")
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end


  # def handle_info(:update, 0) do
  #   broadcast 0, "TIMEEEE"
  #   {:noreply, 0}
  # end

  # def handle_info(:update, time) do
  #   leftover = time - 1
  #   broadcast(0, 0)
  #   schedule_timer(1_000)
  #   {:noreply, leftover}
  # end

  # defp schedule_timer(interval) do
  #   Logger.warn "Schedule timer..."
  #   Process.send_after self(), :update, interval
  # end

  # defp broadcast(_time, _response) do
  #   Logger.warn "broadcasting...."
  #   BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
  #     sym: "test",
  #     price: 1.5,
  #     beast_low: 1.0,
  #     beast_high: 2.0
  #   }
  # end


end
