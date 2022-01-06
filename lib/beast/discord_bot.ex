defmodule Beast.DiscordBot do

  require Logger

  defp is_ticker_in_beast_range(ticker) do
    ticker.price >= ticker.beast_low and ticker.price <= ticker.beast_high
  end

  defp timestamp do
    :os.system_time(:seconds)
  end

  defp option_alert_alpha_text(ticker) do
    "**#{ticker.readable_symbol}**  @   **#{ticker.price}**  in Range [#{ticker.beast_low} - #{ticker.beast_high}],   vwap: #{ticker.vwap},    volume:   #{ticker.volume},   OI: #{ticker.open_interest}"
  end

  defp option_alert_text(ticker) do
    "**#{ticker.readable_symbol}**  @   **#{ticker.price}**  in  Beast Range [#{ticker.beast_low} - #{ticker.beast_high}]"
  end

  defp option_alert_breakout_alpha_text(ticker) do
    "**#{ticker.readable_symbol}**  @   **#{ticker.price}**  breaking out Range [#{ticker.beast_low} - #{ticker.beast_high}],   vwap: #{ticker.vwap},    volume:   #{ticker.volume},   OI: #{ticker.open_interest}"
  end

  defp send_http_post(url, body) do
    # Logger.info("****** SENDING ALERT ****** #{inspect body} ")
    headers = [{"Content-type", "application/json"}]
    response = HTTPoison.post!(url, body, headers, [])
    # Logger.info("****** SENT ALERT ****** #{inspect response} ")
  end


  def send_pt_alerts(ticker) do
    urls = ["https://discordapp.com/api/webhooks/923078848638234685/_E0GVDJk5K8KLswW-Fy6aF2nMG0NBwhyJmZECri0CV3BuI2vw3LwcGH8AzK8UJ1TdPhj"]
    body = Poison.encode!(%{content: option_alert_text(ticker)})
    Enum.map(urls, fn url -> send_http_post(url, body) end)
    ticker
  end

  def send_alpha_alerts(ticker) do
    urls = %{puts: "https://discord.com/api/webhooks/925132918832136332/tQKcqA1UUsS9g59WSCr3kWygDHKCACwzrrYnbvbppfknECM6K8CZbXBztyOsUw1NMX9O",
            calls: "https://discord.com/api/webhooks/925132209176838154/NTLj6VvysBYGmKvhL8IpfBe4yLvmQAAPh0xIQavjnGp8pQY6UfWE2YwNZKlTG5sp4ls5"}
    body = Poison.encode!(%{content: option_alert_alpha_text(ticker)})
    if ticker.type == "C" do
      send_http_post(urls.calls, body)
    else
      send_http_post(urls.puts, body)
    end
    ticker
  end

  def send_breakout_alpha_alerts(ticker) do
    url = "https://discord.com/api/webhooks/928146005759762483/zM3P9VxP-gGhcobghCHQIshySRXR27jtmirXSW2mgLXFxKarUpI9V6kSAaXtCunNxj22"
    body = Poison.encode!(%{content: option_alert_breakout_alpha_text(ticker)})
    send_http_post(url, body)
    ticker
  end

  defp send_alert(ticker) do
    current_time = timestamp()
    if (ticker.last_alerted_at == nil) or (current_time >= ticker.last_alerted_at + 3600) do
      # Logger.warn("**** Sending NORMAL ALERT message ***** - #{inspect option_alert_alpha_text(ticker)}")
      send_alpha_alerts(ticker)
      # send_pt_alerts(ticker)
    end
    ticker
  end

  defp send_breakout_alert(ticker) do
    current_time = timestamp()
    if (ticker.last_breakout_alerted_at == nil) or (current_time >= ticker.last_breakout_alerted_at + 900) do
      # Logger.warn("**** Sending BREAK OUT message ***** - #{inspect option_alert_breakout_alpha_text(ticker)}")
      send_breakout_alpha_alerts(ticker)
    end
    ticker
  end

  defp is_breakout(ticker) do
    breakout? = (ticker.no_of_updates >= 4) and ticker.touched_beast_range? and (ticker.price > ticker.beast_high) and (not ticker.touched_beast_range_now?)
    # Logger.warn("**** TICKER BROKE OUT?***** #{inspect breakout?}  - #{inspect ticker.symbol}")
    breakout?
  end

  def alert(ticker) do
    ticker =
      if is_breakout(ticker) do
            send_breakout_alert(ticker)
            %{ticker | last_breakout_alerted_at: timestamp(), touched_beast_range?: false, touched_beast_range_now?: false}
      else
        ticker
      end
    if is_ticker_in_beast_range(ticker) do
        send_alert(ticker)
        %{ticker | last_alerted_at: timestamp()}
    else
      ticker
    end
  end

end
