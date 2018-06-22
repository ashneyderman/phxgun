defmodule PhxgunTestWeb.PeriodicBrodcaster do
  use GenServer
  use Timex

  def start_link(), do: GenServer.start_link(__MODULE__, [])

  def init(_) do  
    :erlang.send_after(30_000, self(), :broadcast)
    {:ok, 0}
  end

  def handle_info(:broadcast, ref) do
    :erlang.send_after(30_000, self(), :broadcast)
    timestamp = Timex.format!(Timex.now(), "{ISO:Extended:Z}")
    PhxgunTestWeb.Endpoint.broadcast(
      "room:lobby", 
      "broadcast", 
      %{ "message"   => "test msg",
         "timestamp" => timestamp,
         "id"        => ref
      })
    {:noreply, ref + 1}
  end

end