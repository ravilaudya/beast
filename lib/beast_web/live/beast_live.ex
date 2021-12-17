defmodule BeastWeb.BeastLive do
  use BeastWeb, :live_view

  def mount(_params, _session, socket) do
    IO.inspect(socket)
    {:ok, assign(socket, :brightness, 10)}
  end

  def render(assigns) do
    ~L"""
      <h1>Front porch light</h1>
      <%= @brightness %>
    """
  end
end
