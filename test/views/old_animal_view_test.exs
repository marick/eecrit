defmodule Eecrit.OldAnimalViewTest do
  use Eecrit.ConnCase, async: true
  import Phoenix.View
  alias Eecrit.OldAnimalView

  ## :index has two cases: show animals out of service, or just those in service.

  test "only-in-service has affects on the view", %{conn: conn}  do
    content = render_to_string(OldAnimalView, "index.html",
                               conn: conn, animals: [], params: %{})
    assert String.contains?(content, "All animals currently in service")
    assert String.contains?(content, "Include animals out of service")
    assert String.contains?(content, "Date animal will be removed from service")
  end
  
  test "... as does showing out of service animals", %{conn: conn}  do
    content = render_to_string(OldAnimalView, "index.html",
                               conn: conn, animals: [], params: %{"include_out_of_service" => "true"})
    assert String.contains?(content, "All animals, past and present")
    refute String.contains?(content, "Don't show animals that are out of service")
    assert String.contains?(content, "Date animal was or will be removed from service")
  end
end
