defmodule PhxGun.WSClient do
  use GenServer
  require Logger

  defstruct conn: nil,
            heartbeat_timer: nil,
            heartbeat_interval: 30_000,
            ref: 0 

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args)

  def join_channel(socket, channel, params), 
    do: GenServer.cast(socket, {:join_channel, channel, params})

  def init(args) do
    hostname = args |> Keyword.get(:hostname, "localhost")
    path     = args |> Keyword.get(:path, "/socket")
    port     = args |> Keyword.get(:port, 4_000)
    timeout  = args |> Keyword.get(:connect_timeout, 5_000)
    params   = args |> Keyword.get(:params, %{})
    heartbeat_interval = args |> Keyword.get(:heartbeat_interval, 30_000)

    Logger.debug "connecting ..."
    {:ok, conn} = :gun.open(String.to_charlist(hostname), port)
    Logger.debug "waiting ..."
    {:ok, _protocol} = :gun.await_up(conn, timeout)
   
    Logger.debug "upgrading ..."
    :gun.ws_upgrade(conn, to_charlist("#{path}/websocket?#{URI.encode_query(params)}"))
    receive do
      {:gun_ws_upgrade, ^conn, :ok, extra} ->
        Logger.debug "gun_ws_upgrade[(ok): #{inspect extra, pretty: true}"
        {:ok, conn}
      {:gun_response, _, _, _, status, _headers} ->
        Logger.debug "gun_ws_upgrade[error]: #{inspect status, pretty: true}"
        {:stop, status}
    after timeout ->
      Logger.debug "gun_ws_upgrade[error]: timeout"
      {:stop, :timeout}
    end

    Logger.info "args: #{inspect args, pretty: true}"
    tref = :erlang.send_after(heartbeat_interval, self(), :heartbeat)
    {:ok, %__MODULE__{ conn: conn, 
                       heartbeat_timer: tref, 
                       heartbeat_interval: heartbeat_interval }}
  end

  def handle_info(:heartbeat, %__MODULE__{ 
                                conn: conn, 
                                heartbeat_interval: heartbeat_interval,
                                ref: ref }=state) do
    tref = :erlang.send_after(heartbeat_interval, self(), :heartbeat)
    enc_payload = (%{ topic: "phoenix",
                      event: "heartbeat",
                      ref: ref,
                      payload: %{} }) |> Poison.encode!
    :ok = :gun.ws_send(conn, {:text, enc_payload})
    {:noreply, %__MODULE__{ state | heartbeat_timer: tref, ref: ref + 1 }}
  end
  def handle_info({:gun_ws, conn, {:close, code, data}}, %__MODULE__{ conn: conn }=state) do
    Logger.debug "server closed connection: #{inspect code, pretty: true} - #{inspect data, pretty: true}"
    {:stop, :normal, nil}
  end
  def handle_info({:gun_ws, conn, {:text, data}}, %__MODULE__{ conn: conn }=state) do
    Logger.debug "gun_ws text data: #{inspect Poison.decode!(data), pretty: true}"
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

end