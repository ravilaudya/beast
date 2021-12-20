defmodule BeastWeb.OptionLive.Index do
  use BeastWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Beast.Polygon.subscribe()
    {:ok, assign(socket, :data, %{options: Beast.Polygon.get_tickers(), filter: "all"})}
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

  defp beast_range_options(options) do
    options = Enum.filter(options, fn option -> option.price <= option.beast_low end)
    Logger.info("**** RETURNING BEAST ONLY OPTIONS: #{inspect options}")
    options
  end

  @impl true
  def handle_event("beast-range-only", _, socket) do
    Logger.info("DATA: #{inspect socket}")
    {:noreply, update(socket, :data, fn data ->
      %{data | filter: "beast-range", options: beast_range_options(data.options)} end)}
  end
  def handle_event("all-options", _, socket) do
    {:noreply, update(socket, :data, fn data -> %{data | filter: "all", options: Beast.Polygon.get_tickers()} end)}
  end

  def add_option(options, option) do
    exists = Enum.filter(options, fn o -> option.symbol == o.symbol end)
    if exists do
      Enum.map(options, fn x ->
        if option.symbol == x.symbol do
          Logger.info("**** UPDATED OPTION PRICE.... #{inspect option}")
          %{x | price: option.price}
        else
          x
        end
      end)
    else
      Logger.info("**** added as new OPTION.... #{inspect option}")
      [option | options]
    end
  end

  @impl true
  def handle_info({:init, options}, socket) do
    {:noreply, update(socket, :data, fn data -> %{data | options: options} end)}
  end


  @impl true
  def handle_info({:update, option}, socket) do
    Logger.info("UPDATE OPTIONS: #{inspect option}")
    {:noreply, update(socket, :data, fn data ->
      options = add_option(data.options, option)
      if data.filter == "beast-range" do
        %{data | options: beast_range_options(options)}
      else
        %{data | options: options}
      end
    end)}
  end

end
