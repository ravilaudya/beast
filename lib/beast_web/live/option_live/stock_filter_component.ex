defmodule BeastWeb.OptionLive.StockFilterComponent do

  use BeastWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="stock-filter">
        <form phx-submit="stocks_filter">
          <b>Filter Stocks</b> <input type="text" name="stocks_filter" value="" style="width:30%" placeholder="comma separated symbols" />
          <button type="submit">Submit</button>
          <%= if not (@data.stocks_filter == "") do %>
            <b>Selected stocks: <%= @data.stocks_filter %> </b>
          <% end %>
        </form>
      </div>
    """
  end


end
