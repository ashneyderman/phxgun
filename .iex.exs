import PhxGun.WSClient
:observer.start

start_channel_client = fn() ->
  {:ok, conn} = start_link(params: %{ "user_id" => UUID.uuid4 })
  :ok = join_channel(conn, "room:lobby")
  :ok = join_channel(conn, "room:#{UUID.uuid4}")
end