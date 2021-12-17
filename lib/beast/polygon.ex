defmodule Beast.Polygon do
  use WebSockex
  require Logger

  def get_tickers() do
    tickers = [%{ticker: "AM.AAPL211223C00185000", stock: "AAPL", beast_bottom: 0.16, beast_top: 0.21},
              %{ticker: "AM.AAPL211223C00190000", stock: "AAPL", beast_bottom: 0.08, beast_top: 0.11},
              %{ticker: "AM.AAPL211223P00165000", stock: "AAPL", beast_bottom: 0.19, beast_top: 0.3},
              %{ticker: "AM.AAPL211223C00185000", stock: "AAPL", beast_bottom: 0.16, beast_top: 0.21},
              %{ticker: "AM.AAPL211223P00170000", stock: "AAPL", beast_bottom: 0.34, beast_top: 0.51},
              %{ticker: "AM.FB211223C00345000", stock: "FB", beast_bottom: 0.36, beast_top: 0.54, profits: [2.35]},
              %{ticker: "AM.GOOGL211223C02900000", stock: "GOOGL", beast_bottom: 4.29, beast_top: 6.35},
              %{ticker: "AM.GOOGL211223C02950000", stock: "GOOGL", beast_bottom: 2.96, beast_top: 4.4},
              %{ticker: "AM.GOOGL211223C03000000", stock: "GOOGL", beast_bottom: 1.49, beast_top: 2.48},
              %{ticker: "AM.NVDA211223C00300000", stock: "NVDA", beast_bottom: 1.1, beast_top: 1.63},
              %{ticker: "AM.SNOW211223C00400000", stock: "SNOW", beast_bottom: 0.46, beast_top: 0.78}]
    tickers
  end

  def get_tickers_text() do
    tickers = get_tickers()
    Enum.reduce tickers, "", fn x, acc ->
      "#{x.ticker},#{acc}"
    end
  end

  def handle_ticker_update(event) do
    {:ok, sym} = Map.fetch(event, "sym")
    {:ok, _volume} = Map.fetch(event, "v")
    {:ok, _acc_volume} = Map.fetch(event, "av")
    {:ok, _open} = Map.fetch(event, "op")
    {:ok, _vol_wt_avg_price} = Map.fetch(event, "vw")
    {:ok, _window_open} = Map.fetch(event, "o")
    {:ok, window_close} = Map.fetch(event, "c")
    {:ok, _window_high} = Map.fetch(event, "h")
    {:ok, _window_low} = Map.fetch(event, "l")
    {:ok, _today_vol_wt_avg_price} = Map.fetch(event, "a")
    {:ok, _window_avg_trade_size} = Map.fetch(event, "z")
    {:ok, _start_timestamp} = Map.fetch(event, "s")
    {:ok, _end_timestamp} = Map.fetch(event, "e")

    tickers = get_tickers()
    BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
      sym: sym,
      price: window_close,
      beast_low: 1.0,
      beast_high: 2.0
    }

  end

  def handle_status_update(event) do
    BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
      sym: "test",
      price: 1.5,
      beast_low: 1.0,
      beast_high: 2.0
    }
  end


  def parse_event(events) do
    Enum.map(events, fn event ->
      {:ok, type} = Map.fetch(event, "ev")
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
    Logger.info("Subscribing for tickers: #{tickers}")
    {:reply, {:text, Poison.encode!(%{action: "subscribe", params: tickers})}, state}
  end

  def handle_frame({:text, msg}, state) do
    Logger.info("Received Message: #{msg}")
    json_msg = Poison.decode!(msg)
    Logger.info("Decoded message: #{inspect json_msg}")
    parse_event(json_msg)
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


  # def init(_state) do
  #   Logger.warn "Beast server started"
  #   # broadcast(30, "Started timer!")
  #   # schedule_timer(1_000) # 1 sec timer
  #   {:ok, 30}
  # end

  # def handle_info(:update, 0) do
  #   broadcast 0, "TIMEEEE"
  #   {:noreply, 0}
  # end

  # def handle_info(:update, time) do
  #   leftover = time - 1
  #   broadcast leftover, "tick tock... tick tock"
  #   schedule_timer(1_000)
  #   {:noreply, leftover}
  # end

  # defp schedule_timer(interval) do
  #   Logger.warn "Schedule timer..."
  #   Process.send_after self(), :update, interval
  # end

  # defp broadcast(time, response) do
  #   Logger.warn "broadcasting....#{time}"
  #   BeastWeb.Endpoint.broadcast! "room:lobby", "new_msg", %{
  #     response: response,
  #     time: time,
  #   }
  # end


end
