defmodule Eecrit.OldAnimalViewTest do
  use Eecrit.ConnCase, async: true
  import Phoenix.View
  import Eecrit.Router.Helpers
  alias Eecrit.OldAnimalView

  ## :index has two cases: show animals out of service, or just those in service.

  test "only-in-service has affects on the view", %{conn: conn}  do
    content = render_to_string(OldAnimalView, "index.html",
                               conn: conn, animals: [], params: %{})
    assert String.contains?(content, "All animals currently in service")
    assert String.contains?(content, "Include animals out of service")
    refute String.contains?(content, "Date removed from service")
  end
  
  test "... as does showing out of service animals", %{conn: conn}  do
    content = render_to_string(OldAnimalView, "index.html",
                               conn: conn, animals: [], params: %{"include_out_of_service" => "true"})
    assert String.contains?(content, "All animals")
    refute String.contains?(content, "Don't show animals that are out of service")
    assert String.contains?(content, "Date removed from service")
  end
end
