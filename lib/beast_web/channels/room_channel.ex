defmodule BeastWeb.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Phoenix.Socket.Broadcast

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    Logger.warn("Got message.... in room channell...")
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  def handle_out(room, msg, socket) do
    Logger.warn("------------- HANDLE OUT ------------")
    push(socket, room, msg)
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    Logger.warn("------------- BROADCAST ------------")
    push(socket, event, payload)
    {:noreply, socket}
  end
end
