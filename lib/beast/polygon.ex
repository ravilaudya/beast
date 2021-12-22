defmodule Beast.Polygon do
  use WebSockex
  require Logger
  require Beast.TickerAgent
  require Beast.DiscordBot

  def get_tickers() do
    #tickers = [%{symbol: "O:MSFT211223P00315000", open: 0.0, volume: 1000, vwap: 0.0,  targets: "", readable_symbol: "MSFT211223P00315000", price: 0.0, stock: "MSFT", beast_low: 0.20, beast_high: 0.29},]
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
    av = Map.get(event, "av")
    open = Map.get(event, "op")
    vwap = Map.get(event, "vw")
    _window_open = Map.get(event, "o")
    window_close = Map.get(event, "c")
    _window_high = Map.get(event, "h")
    _window_low = Map.get(event, "l")
    _today_vol_wt_avg_price = Map.get(event, "a")
    _window_avg_trade_size = Map.get(event, "z")
    _start_timestamp = Map.get(event, "s")
    _end_timestamp = Map.get(event, "e")

    ticker = find_ticker(sym)
    # Logger.warn("FOUND TICKER: #{inspect ticker}")

    updated_ticker = %{ticker | price: window_close, open: open, volume: av, vwap: vwap}
                    |> Beast.DiscordBot.alert
    Beast.TickerAgent.update(updated_ticker)
    broadcast({:update, updated_ticker})
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
    end)
    Process.sleep(1000)
    handle_frame({:text, "hello"}, ['awesome elixir'])
  end

  def start_link(state) do
    {:ok, pid}  = WebSockex.start_link("wss://socket.polygon.io/options", __MODULE__, state)
    # Logger.warn("Started POLYGON CLIENT...#{inspect pid}")
    {:ok, pid}
  end

  def handle_frame({:text, "[{\"ev\":\"status\",\"status\":\"connected\",\"message\":\"Connected Successfully\"}]" = msg}, state) do
    Logger.info("Received Message: #{msg}")
    {:reply, {:text, Poison.encode!(%{action: "auth", params: "X5ndpVseKPBdJ6MbIyiaB1tvqJBmcHSe"})}, state}
  end

  def handle_frame({:text, "[{\"ev\":\"status\",\"status\":\"auth_success\",\"message\":\"authenticated\"}]" = msg}, state) do
    Logger.info("Received Message: #{msg}")
    tickers = get_tickers()
    # Logger.info("GOT TICKERS: #{inspect tickers}")
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
    [%{"ev" => "AM", "sym" => Map.get(ticker, :symbol),
       "c" => Enum.random(10..200) / 100,
       "av" => Enum.random(1000..20000),
       "vw" => Enum.random(10..200) / 100,
       "op" => Enum.random(10..200) / 100}]
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Beast.PubSub, "options")
  end

end
