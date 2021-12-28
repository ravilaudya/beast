defmodule BeastWeb.OptionLive.StockFilterComponent do

  use BeastWeb, :live_component

  def render(assigns) do
    ~H"""
      <form phx-submit="stocks_filter">
        <input type="text" name="stocks_filter" value="" />
        <button type="submit">Submit</button>
        <b>Selected stocks: <%= @data.stocks_filter %> </b>
      </form>
    """
  end


end
