defmodule PhxGun.WSClient do
  use GenServer
  require Logger
  use Elixometer

  defstruct conn: nil,
            heartbeat_timer: nil,
            heartbeat_interval: 30_000,
            ref: 0,
            sink: nil,
            channels: %{} 

  def start_link(args \\ []),
    do: GenServer.start_link(__MODULE__, args, timeout: :infinity)

  def join_channel(socket, channel, params \\ nil), 
    do: GenServer.cast(socket, {:join_channel, channel, params})

  def leave_channel(socket, channel),
    do: GenServer.cast(socket, {:leave_channel, channel})

  def init(args) do
    hostname  = args |> Keyword.get(:hostname, "localhost")
    path      = args |> Keyword.get(:path, "/socket")
    port      = args |> Keyword.get(:port, 4_000)
    timeout   = args |> Keyword.get(:connect_timeout, 5_000)
    params    = args |> Keyword.get(:params, %{})
    heartbeat = args |> Keyword.get(:heartbeat_interval, 30_000)

    Logger.debug "connecting ..."
    {:ok, conn} = :gun.open(String.to_charlist(hostname), port)
    with {:ok, _}    <- :gun.await_up(conn, timeout),
         {:ok, _}    <- upgrade_to_websocket(conn, path, params, timeout) do
      # report connected client
      update_counter("webscoket_conns", 1)
      tref = :erlang.send_after(heartbeat, self(), :heartbeat)
      {:ok, %__MODULE__{ conn: conn, 
                         heartbeat_timer: tref, 
                         heartbeat_interval: heartbeat }}
    else
      {:error, error} ->
        :gun.close(conn)
        {:stop, error}
      error -> 
        :gun.close(conn)
        Logger.error "Unknown error connecting #{inspect error, pretty: true}"
        {:stop, error}
    end
  end
 
  def handle_info(:heartbeat, %__MODULE__{ conn: conn, 
                                           heartbeat_interval: heartbeat,
                                           ref: ref }=state) do
    tref = :erlang.send_after(heartbeat, self(), :heartbeat)
    enc_payload = (%{ topic: "phoenix",
                      event: "heartbeat",
                      ref: ref,
                      payload: %{} }) |> Poison.encode!
    :ok = :gun.ws_send(conn, {:text, enc_payload})
    {:noreply, %__MODULE__{ state | heartbeat_timer: tref, ref: ref + 1 }}
  end
  def handle_info({:gun_ws, conn, {:close, code, data}}, %__MODULE__{ conn: conn }=state) do
    update_counter("webscoket_conns", -1)
    Logger.debug "server closed connection: #{inspect code, pretty: true} - #{inspect data, pretty: true}"
    {:stop, :normal, nil}
  end
  def handle_info({:gun_down, conn, :ws, :closed, _, _}, %__MODULE__{ conn: conn }=state) do
    update_counter("webscoket_conns", -1)
    {:stop, :normal, nil}
  end 
  def handle_info({:gun_ws, conn, {:text, data}}, %__MODULE__{ conn: conn }=state) do
    phx_packet = Poison.decode!(data)
    if (phx_packet["topic"] == "room:lobby") do
      Logger.debug """
        room:lobby: #{phx_packet["payload"]["user_id"]} 
        #{phx_packet["payload"]["timestamp"]}
        #{phx_packet["payload"]["message"]}

      """
    end
    {:noreply, state}
  end

  def handle_cast({:join_channel, channel, params}, %__MODULE__{ conn: conn, ref: ref }) do
    enc_payload = %{topic: channel,
                    payload: params || %{},
                    event: "phx_join",
                    ref: ref} |> Poison.encode!
    :ok = :gun.ws_send(conn, {:text, enc_payload})
    {:noreply, %__MODULE__{ conn: conn, ref: ref+1 }}
  end

  def handle_cast({:leave_channel, channel}, %__MODULE__{ conn: conn, ref: ref }) do
    enc_payload = %{topic: channel,
                    payload: %{},
                    event: "phx_leave",
                    ref: ref} |> Poison.encode!
    :ok = :gun.ws_send(conn, {:text, enc_payload})
    {:noreply, %__MODULE__{ conn: conn, ref: ref+1 }}
  end

  defp upgrade_to_websocket(conn, path, params, timeout) do
    with :ok == :gun.ws_upgrade(conn, to_charlist("#{path}/websocket?#{URI.encode_query(params)}")) do
      receive do
        {:gun_ws_upgrade, ^conn, :ok, extra} ->
          Logger.debug "gun_ws_upgrade[(ok): #{inspect extra, pretty: true}"
          {:ok, conn}
        {:gun_response, _, _, _, status, _headers} ->
          Logger.debug "gun_ws_upgrade[error]: #{inspect status, pretty: true}"
          {:error, status}
      after timeout ->
        Logger.debug "gun_ws_upgrade[error]: timeout"
        {:error, :timeout}
      end
    else
      error -> {:error, error}
    end
  end

end