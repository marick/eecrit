defmodule Eecrit.AnimalUseViewTest do
  use Eecrit.ViewCase, async: true
  alias Eecrit.ReportView
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure

  setup c do
    a1 = %{id: 11, name: "this-is-animal-1"}
    p1 = %{id: 111, name: "this-is-procedure-1", use_count: "stands-for-a-use-count"}
    view_model = [[a1, p1]]
    
    html = render_to_string(ReportView, "animal_use.html",
      conn: c.conn, view_model: view_model)

    provides([a1, p1, html])
  end

  test "names appear", c do
    c.html
    |> matches!(c.a1.name)
    |> matches!(c.p1.name)
    |> matches!(c.p1.use_count)
  end

  test "outgoing links", c do
    c.html
    |> allows_show!([OldAnimal, c.a1.id], text: c.a1.name)
    |> allows_show!([OldProcedure, c.p1.id], text: c.p1.name)
  end    
end
