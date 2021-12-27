defmodule Beast.DiscordBot do

  require Logger

  defp is_ticker_in_beast_range(ticker) do
    ticker.price >= ticker.beast_low and ticker.price <= ticker.beast_high
  end

  defp timestamp do
    :os.system_time(:seconds)
  end

  defp option_alert_alpha_text(ticker) do
    "**#{ticker.readable_symbol}**  @   **#{ticker.price}**  in Range [#{ticker.beast_low} - #{ticker.beast_high}],   vwap: **#{ticker.vwap}**,    volume:   **#{ticker.volume}**"
  end

  defp option_alert_text(ticker) do
    "**#{ticker.readable_symbol}**  @   **#{ticker.price}**  in  Beast Range [#{ticker.beast_low} - #{ticker.beast_high}]"
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
    %{ticker | last_alerted_at: timestamp()}
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
    %{ticker | last_alerted_at: timestamp()}
  end

  defp send_alert(ticker) do
    send_alpha_alerts(ticker)
    send_pt_alerts(ticker)
  end

  def alert(ticker) do
    if is_ticker_in_beast_range(ticker) do
      last_alerted_at = ticker.last_alerted_at
      case last_alerted_at do
        nil -> send_alert(ticker)
        _ ->
          current_time = timestamp()
          if current_time >= last_alerted_at + 3600 do
            send_alert(ticker)
          else
            ticker
          end
      end
    else
      ticker
    end
  end

end
