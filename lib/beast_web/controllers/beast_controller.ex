defmodule BeastWeb.BeastController do
  use BeastWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end