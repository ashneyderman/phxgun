defmodule PhxgunTestWeb.RoomChannel do
  use Phoenix.Channel
  
  def join("room:" <> user_id, %{}, socket) do
    :erlang.send_after(1000, self(), "nudge")
    {:ok, assign(socket, :room_counter, 0)}
  end

  def handle_info("nudge", socket) do
    :erlang.send_after(10000, self(), "nudge")
    counter = socket.assigns[:room_counter]
    push socket, "nudge", %{id: counter, message: "on interval"}
    {:noreply, assign(socket, :room_counter, counter + 1)}
  end
end
