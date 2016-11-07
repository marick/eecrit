defmodule Eecrit.UserSocket do
  use Phoenix.Socket
  alias Eecrit.SessionPlugs
  import Logger

  ## Channels
  # channel "room:*", Eecrit.RoomChannel
  channel "counter", Eecrit.C4uChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"auth_token" => auth_token}, socket) do
    case Phoenix.Token.verify(socket, SessionPlugs.auth_token_name, auth_token) do
      {:ok, user_id} ->
        Logger.info "Connection for user #{user_id}"
        {:ok, assign(socket, :user_id, user_id)}
      {:error, reason} ->
        Logger.warn "Connection attempt failed authentication: #{reason}"
        :error
    end
  end

  def connect(params, socket) do
    Logger.warn "Connection attempt with no authentication token"
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Eecrit.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket) do
    "users_socket:#{socket.assigns.user_id}"
  end
end
