defmodule Eecrit.AnimalUseViewTest do
  use Eecrit.ViewCase, async: true
  alias Eecrit.ReportView
  alias Eecrit.ViewModel, as: VM

  setup c do
    a1 = make_old_animal(id: 11, name: "this-is-animal-1")
    a1v = VM.animal(a1)
    p1 = make_old_procedure(id: 111, name: "this-is-procedure-1")
    p1v = VM.procedure(p1, use_count: "stands-for-a-use-count")
    view_model = [[a1v, p1v]]
    
    html = render_to_string(ReportView, "animal_use.html",
      conn: c.conn, view_model: view_model,
      input_data: %{first_date: "first", last_date: "last"})

    provides([a1, a1v, p1, p1v, html])
  end

  test "names appear", c do
    c.html
    |> matches!(c.a1v.name)
    |> matches!(c.p1v.name)
    |> matches!(c.p1v.use_count)
  end

  test "outgoing links", c do
    c.html
    |> allows_show!(c.a1, text: c.a1.name)
    |> allows_show!(c.p1, text: c.p1.name)
    |> allows_anchor!(:animal_reservations,
         [:report_path, animal: c.a1.id, first_date: "first", last_date: "last"],
         text: "See reservations")
  end    
end
