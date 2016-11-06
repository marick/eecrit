defmodule Eecrit.C4uChannel do
  use Eecrit.Web, :channel

  def join("c4u", _params, socket) do
    IO.puts "Got join request on #{inspect socket}"
    :timer.send_interval(5_000, :ping)
    {:ok, socket}
  end

  def handle_info(:ping, socket) do
    IO.puts "Ping!"
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count}
    {:noreply, assign(socket, :count, count+1)}
  end
end
