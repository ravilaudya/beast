defmodule BeastWeb.OptionLive.Index do
  use BeastWeb, :live_view

  alias Beast.Options
  alias Beast.Options.Option
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Beast.Polygon.subscribe()
    {:ok, socket
          |> assign(:options, Beast.Polygon.get_tickers())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Option")
    |> assign(:option, Options.get_option!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Option")
    |> assign(:option, %Option{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Beast Options")
    |> assign(:option, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    option = Options.get_option!(id)
    {:ok, _} = Options.delete_option(option)

    {:noreply, assign(socket, :options, list_options())}
  end
  def handle_event("beast-range-only", _, socket) do
    {:noreply,
      socket
      |> update(:options, fn options->
                Enum.filter(options, fn x -> x.price <= x.beast_low end)
                end)
      |> update(:beast_only, fn _ -> true end)
    }
  end
  def handle_event("all-options", _, socket) do
    {:noreply,
      socket
      |> update(:options, fn options-> Beast.Polygon.get_tickers() end)
      |> update(:beast_only, fn _ -> false end)
    }
  end

  @impl true
  def handle_info({:init, options}, socket) do
    {:noreply, update(socket, :options, fn _ -> options end)}
  end


  @impl true
  def handle_info({:update, option}, socket) do
    {:noreply, update(socket, :options, fn options->
      Enum.map(options, fn x ->
        if option.symbol == x.symbol do
          %{x | price: option.price}
        else
          x
        end
      end)
    end)}
  end

  defp list_options do
    Options.list_options()
  end
end
