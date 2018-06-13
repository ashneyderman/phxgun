defmodule PhxgunTest do
  use ExUnit.Case
  require Logger
  
  # test "greets the world1" do
  #   IO.puts "greets the world1: #{inspect self(), pretty: true}"
  #   assert "world" = PhxGun.hello()
  #   s = self()
  #   Process.spawn(fn() -> 
  #     Process.send_after(s, "done", 200)
  #     Process.send_after(s, "done", 200)
  #   end, [])
  #   assert_receive "done", 1000, "Did not receieve a message within 1 second"
  #   assert_receive "done", 0, "Did not receieve a message within 1 second"
  # end

  test "proposed interface" do
    {:ok, conn} = PhxGun.connect("localhost", 4000, 5000)
    Logger.info "conn: #{inspect conn, pretty: true}"
  end

end
