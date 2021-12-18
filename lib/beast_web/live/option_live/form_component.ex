defmodule BeastWeb.OptionLive.FormComponent do
  use BeastWeb, :live_component

  alias Beast.Options

  @impl true
  def update(%{option: option} = assigns, socket) do
    changeset = Options.change_option(option)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"option" => option_params}, socket) do
    changeset =
      socket.assigns.option
      |> Options.change_option(option_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"option" => option_params}, socket) do
    save_option(socket, socket.assigns.action, option_params)
  end

  defp save_option(socket, :edit, option_params) do
    case Options.update_option(socket.assigns.option, option_params) do
      {:ok, _option} ->
        {:noreply,
         socket
         |> put_flash(:info, "Option updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_option(socket, :new, option_params) do
    case Options.create_option(option_params) do
      {:ok, _option} ->
        {:noreply,
         socket
         |> put_flash(:info, "Option created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
