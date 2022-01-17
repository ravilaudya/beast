require Logger

defmodule OptionReader do
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

  def get_tickers() do
    {:ok, contents} = File.read("./options-res.txt")
    split_contents = String.split(contents, "\n")
    Enum.map(split_contents, fn line ->
      list = String.split(line)
      beast_low = safe_parse_float(Enum.at(list, 3))
      beast_high = safe_parse_float(Enum.at(list, 5))
      targets = generate_targets(list)
      targets = String.split(targets, ", ")
      %{symbol: Enum.at(list, 0), beast_low: beast_low, beast_high: beast_high, targets: targets}
    end)
  end
end

study = "input cloud = Yes;\ninput Alarm = No;\n"
study = "#{study} def AuxRilla = "

tickers = OptionReader.get_tickers()
bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
  prefix = if (acc.counter == 0), do: "", else: "      else "
  %{acc | counter: acc.counter + 1,
          study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{inspect ticker.beast_low}\n"}
end)
study = "#{bl_study.study} else 0.0;\n"

study = "#{study} def Gorilla = "
bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
  prefix = if (acc.counter == 0), do: "", else: "      else "
  %{acc | counter: acc.counter + 1,
          study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{inspect ticker.beast_high}\n"}
end)
study = "#{bl_study.study} else 0.0;\n"

# study = "#{study} def TP1 = "
# bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
#   prefix = if (acc.counter == 0), do: "", else: "      else "
#   %{acc | counter: acc.counter + 1,
#           study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{Enum.at(ticker.targets, 0)}\n"}
# end)
# study = "#{bl_study.study} else 0.0;\n"

# study = "#{study} def TP2 = "
# bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
#   prefix = if (acc.counter == 0), do: "", else: "      else "
#   %{acc | counter: acc.counter + 1,
#           study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{Enum.at(ticker.targets, 1)}\n"}
# end)
# study = "#{bl_study.study} else 0.0;\n"


# study = "#{study} def TP3 = "
# bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
#   prefix = if (acc.counter == 0), do: "", else: "      else "
#   %{acc | counter: acc.counter + 1,
#           study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{Enum.at(ticker.targets, 2)}\n"}
# end)
# study = "#{bl_study.study} else 0.0;\n"


# study = "#{study} def TP4 = "
# bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
#   prefix = if (acc.counter == 0), do: "", else: "      else "
#   %{acc | counter: acc.counter + 1,
#           study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{Enum.at(ticker.targets, 3)}\n"}
# end)
# study = "#{bl_study.study} else 0.0;\n"

# study = "#{study} def TP5 = "
# bl_study = Enum.reduce(tickers, %{counter: 0, study: study}, fn ticker, acc ->
#   prefix = if (acc.counter == 0), do: "", else: "      else "
#   %{acc | counter: acc.counter + 1,
#           study: "#{acc.study} #{prefix} if (GetSymbol() == \"#{ticker.symbol}\") then #{Enum.at(ticker.targets, 4)}\n"}
# end)
# study = "#{bl_study.study} else 0.0;\n"

IO.puts(study)
