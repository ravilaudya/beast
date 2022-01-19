defmodule BeastWeb.OptionLive.Index do
  use BeastWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Beast.Polygon.subscribe()
    options =
    try do
      fetch_options(nil)
    rescue
      _e -> []
    end
    updated_at = Beast.TickerAgent.last_updated_at()
    tos_study = Beast.TickerAgent.tos_study()
    {:ok, assign(socket, :data, %{options: options,
                                  filter: "all", type: "all",
                                  last_updated_at: updated_at,
                                  tos_study: tos_study,
                                  stocks_filter: ""})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Beast Options")
    |> assign(:option, nil)
  end

  @impl true
  def handle_event("beast-range-only", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | filter: "beast-range", options: fetch_options(%{data | filter: "beast-range"})} end)}
  end
  def handle_event("all-options", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | filter: "all", options: fetch_options(%{data | filter: "all"})} end)}
  end
  def handle_event("all-types", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | type: "all", options: fetch_options(%{data | type: "all"})} end)}
  end
  def handle_event("calls-only", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | type: "calls-only", options: fetch_options(%{data | type: "calls-only"})} end)}
  end
  def handle_event("puts-only", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | type: "puts-only", options: fetch_options(%{data | type: "puts-only"})} end)}
  end
  def handle_event("stocks_filter", %{"stocks_filter" => stocks_filter}, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | stocks_filter: stocks_filter, options: fetch_options(%{data | stocks_filter: stocks_filter})} end)}
  end
  def handle_event(event, _, socket) do
    Logger.error("**** Error handling event #{inspect event}. No matching handler")
    {:noreply, update(socket, :data, fn data -> data end)}
  end

  @impl true
  def handle_info({:init, options}, socket) do
    {:noreply, update(socket, :data, fn data -> %{data | options: options} end)}
  end
  @impl true
  def handle_info({:update, _option}, socket) do
    {:noreply, update(socket, :data, fn data ->
      options = Beast.Polygon.get_tickers()
                |> filter_beast_options(data.filter)
                |> filter_zero_values
                |> filter_by_type(data.type)
                |> filter_by_stocks(data.stocks_filter)
      %{data | options: options}
    end)}
  end

  defp fetch_options(nil), do: Beast.Polygon.get_tickers()
  defp fetch_options(data) do
    Beast.Polygon.get_tickers()
      |> filter_by_type(data.type)
      |> filter_beast_options(data.filter)
      |> filter_zero_values
      |> filter_by_stocks(data.stocks_filter)
  end

  defp filter_by_stocks(options, nil), do: options
  defp filter_by_stocks(options, ""), do: options
  defp filter_by_stocks(options, stocks_filter) do
    stocks = String.split(stocks_filter, ",")
    Enum.filter(options, fn option -> Enum.member?(stocks, String.downcase(option.stock)) end)
  end

  defp filter_by_type(options, type) do
    case type do
      "all" -> options
      "calls-only" -> Enum.filter(options, fn option -> option.type == "C" end)
      "puts-only" -> Enum.filter(options, fn option -> option.type == "P" end)
      _ -> options
    end
  end

  defp filter_zero_values(options) do
    Enum.filter(options, fn option -> option.price > 0 end)
  end

  defp filter_beast_options(options, filter) do
    case filter do
      "beast-range" -> Enum.filter(options, fn option -> option.price >= option.beast_low and option.price <= option.beast_high end)
      "all" -> options
      _ -> options
    end
  end

end
