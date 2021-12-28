defmodule BeastWeb.OptionLive.StockFilterComponent do

  use BeastWeb, :live_component

  def render(assigns) do
    ~H"""
      <form phx-submit="stocks_filter">
        <input type="text" name="stocks_filter" value="" />
        <button type="submit">Submit</button>
        <%= if not (@data.stocks_filter == "") do %>
          <b>Selected stocks: <%= @data.stocks_filter %> </b>
        <% end %>
      </form>
    """
  end


end
