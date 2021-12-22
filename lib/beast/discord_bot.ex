defmodule Beast.DiscordBot do

  require Logger

  defp is_ticker_in_beast_range(ticker) do
    ticker.price <= ticker.beast_low
  end

  defp timestamp do
    :os.system_time(:seconds)
  end

  defp option_alert_text(ticker) do
    "**#{ticker.readable_symbol}**  @   **#{ticker.price}**   Beast Range [#{ticker.beast_low} - #{ticker.beast_high}],     VWAP: #{ticker.vwap},     Volume: #{ticker.volume},     OI: #{ticker.open_interest}"
  end

  defp send_http_post(url, body) do
    Logger.info("****** SENDING ALERT ****** #{inspect body} ")
    headers = [{"Content-type", "application/json"}]
    response = HTTPoison.post!(url, body, headers, [])
    Logger.info("****** SENT ALERT ****** #{inspect response} ")
  end

  defp send_alert(ticker) do
    urls = ["https://discord.com/api/webhooks/923079224141676584/3BQaQltxpU-JiYP0BdMDQ1ZTRj8dLBolnVLUO2yaVctYLL4jm--D8Cdt_EQ0_kbEsV6j",
           "https://discordapp.com/api/webhooks/923078848638234685/_E0GVDJk5K8KLswW-Fy6aF2nMG0NBwhyJmZECri0CV3BuI2vw3LwcGH8AzK8UJ1TdPhj"]
    body = Poison.encode!(%{content: option_alert_text(ticker)})
    Enum.map(urls, fn url -> send_http_post(url, body) end)
    %{ticker | last_alerted_at: timestamp()}
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
