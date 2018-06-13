defmodule PhxGun do
  require Logger

  @doc """
  
  """
  # @spec 
  def connect(url, port, timeout \\ 5000) do
    Logger.info "connecting ..."
    {:ok, conn} = :gun.open(String.to_charlist(url), port)
    Logger.info "waiting ..."
    {:ok, _protocol} = :gun.await_up(conn, timeout)
    
    params = %{ "user_id" => 123 }
    Logger.info "upgrading ..."
    :gun.ws_upgrade(conn, to_charlist("/socket/websocket?#{URI.encode_query(params)}"))
    receive do
      {:gun_ws_upgrade, ^conn, :ok, extra} ->
        Logger.info "gun_ws_upgrade[(ok): #{inspect extra}"
        {:ok, conn}
      {:gun_response, _, _, _, status, _headers} ->
        Logger.info "gun_ws_upgrade[error]: #{inspect status}"
        {:error, status}
    after timeout ->
      Logger.info "gun_ws_upgrade[error]: timeout"
      {:stop, :timeout}
    end
  end

#   def 
#   r = fn() ->
#   {:ok, _} = PhxGun.connect("localhost", 4000, 5000)
#   fun = fn(f) ->
#     receive do
#       {:gun_ws, _, {:close, _, _}} -> :ok
#       msg ->
#         Logger.info "msg: #{inspect msg, pretty: true}"
#         f.(f)
#     end
#   end
#   fun.(fun)
# end

  # end

  # def join_channel()

  # def leave_channel()

  def hello, do: "world"

end
