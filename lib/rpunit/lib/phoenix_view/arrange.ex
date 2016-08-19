defmodule RoundingPegs.ExUnit.PhoenixView.Arrange do
  alias Phoenix.ConnTest
  
  @doc """
  This avoids actual routing, but it does pass a connection through 
  the `:browser` plugs. Note that it currently does not include
  plugs specific to a controller.

  The router and endpoints are those of the application. The module-implicit
  @endpoint isn't used because I ended up having to declare it in too many
  places.
  """
  # TODO: This does not include plugs specific to the controller
  def simulate_browser_routing(conn, router, endpoint) do
    conn
    |> ConnTest.bypass_through(router, :browser)
    |> ConnTest.dispatch(endpoint, :get, "..irrelevant path..")
  end
end
