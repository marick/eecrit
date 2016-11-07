defmodule Eecrit.C4uChannel do
  use Eecrit.Web, :channel
  import Logger

  def join("c4u", _params, socket) do
    Logger.info "Got join request for c4u"
    :timer.send_interval(5_000, :ping)
    {:ok, socket}
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count}
    {:noreply, assign(socket, :count, count+1)}
  end

  def handle_in("value", params, socket) do
    Logger.info "Setting ping count to #{params["value"]}"
    {:noreply, assign(socket, :count, params["value"])}
  end
end
