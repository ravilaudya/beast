defmodule BeastWeb.OptionLive.Index do
  use BeastWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Beast.Polygon.subscribe()
    {:ok, assign(socket, :data, %{options: fetch_options("all", "all"), filter: "all", type: "all"})}
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
      %{data | filter: "beast-range", options: fetch_options(data.type, "beast-range")} end)}
  end
  def handle_event("all-options", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | filter: "all", options: fetch_options(data.type, "all")} end)}
  end
  def handle_event("all-types", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | type: "all", options: fetch_options("all", data.filter)} end)}
  end
  def handle_event("calls-only", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | type: "calls-only", options: fetch_options("calls-only", data.filter)} end)}
  end
  def handle_event("puts-only", _, socket) do
    {:noreply, update(socket, :data, fn data ->
      %{data | type: "puts-only", options: fetch_options("puts-only", data.filter)} end)}
  end

  @impl true
  def handle_info({:init, options}, socket) do
    {:noreply, update(socket, :data, fn data -> %{data | options: options} end)}
  end
  @impl true
  def handle_info({:update, option}, socket) do
    {:noreply, update(socket, :data, fn data ->
      options = Beast.Polygon.get_tickers()
                |> filter_beast_options(data.filter)
                |> filter_zero_values
                |> filter_by_type(data.type)
      %{data | options: options}
    end)}
  end

  defp fetch_options(type, filter) do
    Beast.Polygon.get_tickers()
      |> filter_by_type(type)
      |> filter_beast_options(filter)
      |> filter_zero_values
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
