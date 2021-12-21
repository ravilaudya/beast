defmodule BeastWeb.OptionLive.OptionComponent do

  use BeastWeb, :live_component

  def render(assigns) do
    ~H"""
      <td>
        <b><%= @option.readable_symbol %></b>
      </td>
      <td>
        <b><%= @option.price %></b>
      </td>
      <td>
        <b><%= @option.beast_low %></b>
      </td>
      <td>
        <b><%= @option.beast_high %></b>
      </td>
      <td>
        <b><%= @option.open %></b>
      </td>
      <td>
        <b><%= @option.vwap %></b>
      </td>
      <td>
        <b>[ <%= @option.targets %> ]</b>
      </td>
    """
  end


end
