defmodule BeastWeb.OptionLive.OptionComponent do

  use BeastWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="option">
      <div class="row">
        <div class="column column-40 option-symbol">
          <b><%= @option.readable_symbol %></b>
        </div>
        <div class="column column-10 option-price">
          <b><%= @option.price %></b>
        </div>
        <div class="column column-10 option-beast-low">
          <b><%= @option.beast_low %></b>
        </div>
        <div class="column column-10 option-beast-high">
          <b><%= @option.beast_high %></b>
        </div>
        <div class="column column-30 option-beast-high">
          <b><%= @option.targets %></b>
        </div>
      </div>
    </div>
    """
  end


end
