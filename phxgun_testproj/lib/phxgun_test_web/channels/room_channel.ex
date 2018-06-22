defmodule PhxgunTestWeb.RoomChannel do
  use Phoenix.Channel
  use Timex
  
  intercept ["broadcast"]

  def handle_out("broadcast", payload, socket) do
    push socket, "broadcast", Map.put(payload, :user_id, socket.assigns[:user_id])
    {:noreply, socket}
  end

  def join("room:lobby", _, socket) do
    {:ok, socket}
  end
  def join("room:" <> user_id, %{}, socket) do
    :erlang.send_after(1_000, self(), "nudge")
    {:ok, assign(socket, :room_counter, 0)
          |> assign(:user_id, user_id)}
  end

  def handle_info("nudge", socket) do
    :erlang.send_after(10_000, self(), "nudge")
    user_id   = socket.assigns[:user_id]
    counter   = socket.assigns[:room_counter]
    timestamp = Timex.format!(Timex.now(), "{ISO:Extended:Z}")
    message   = "User with ID: #{user_id} on interval of 10 seconds." 
    push(socket, 
         "nudge", 
         %{id: counter, 
           message: message,
           timestamp: timestamp
         })
    {:noreply, assign(socket, :room_counter, counter + 1)}
  end
end
