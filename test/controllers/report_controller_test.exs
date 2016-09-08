defmodule Eecrit.ReportControllerTest do
  use Eecrit.ConnCase
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.ReportController, as: S
  alias Eecrit.OldReservationSink

  @valid_attrs %{is_admin: true, is_superuser: true, name: "some content"}
  @invalid_attrs %{name: ""}
  @intended_for "admin"

  ### Authorization

  @tag accessed_by: "user"
  test "anyone less than admin does not have access", %{conn: conn} do
    conn = get conn, report_path(conn, :animal_use)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  @tag accessed_by: "anonymous"
  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, report_path(conn, :animal_use)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  #### UTIL

  test "convert to final view model" do
    animals = [%OldAnimal{id: 11, name: "a1"},
               %OldAnimal{id: 33, name: "a3"},
               %OldAnimal{id: 22, name: "a2"},
              ]

    procedures = [%OldProcedure{id: 111, name: "p1"},
                  %OldProcedure{id: 333, name: "p3"},
                  %OldProcedure{id: 222, name: "p2"},
                 ]

    uses = [{11, 111, 1},
            {11, 222, 2},
            {22, 111, 3},
            {22, 333, 4},
           ]

    expected = 
      [ [%{id: 11, name: "a1"}, %{id: 111, name: "p1", use_count: 1},
                               %{id: 222, name: "p2", use_count: 2}],
        [%{id: 22, name: "a2"}, %{id: 111, name: "p1", use_count: 3},
                                %{id: 333, name: "p3", use_count: 4}],
        [%{id: 33, name: "a3"}],
      ]
    assert S.view_model(animals, procedures, uses) == expected
  end

  test "aggregate_use_counts" do
    uses = [{11, 111, 1},
            {11, 222, 2},
            {11, 111, 3},   # note animal/procedure key
            {22, 333, 4},
           ]
    expected = [{11, 111, 4},
                {11, 222, 2},
                {22, 333, 4},
               ]
    actual = S.aggregate_use_counts(uses)

    assert MapSet.new(actual) == MapSet.new(expected)
  end


  #### END TO END

  def insert_ranged_reservation!({first_date, last_date}, animals, procedures) do 
    make_old_reservation_fields(first_date: first_date, last_date: last_date)
    |> OldReservationSink.make_full!(animals, procedures)
  end

  test "end-to-end" do
    one_month = {"2016-06-01", "2016-06-30"}
    
    a1 = insert_old_animal(name: "a1")
    a2 = insert_old_animal(name: "a2")
    a3 = insert_old_animal(name: "a3")

    p1 = insert_old_procedure(name: "p1")
    p2 = insert_old_procedure(name: "p2")
    p3 = insert_old_procedure(name: "p3")

    a = fn a -> %{id: a.id, name: a.name} end
    p = fn p, count -> %{id: p.id, name: p.name, use_count: count} end

    insert_ranged_reservation!({"2016-06-01", "2016-06-01"}, [a1], [p1])
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 1)],
      [a.(a2)],
      [a.(a3)],
    ]

    insert_ranged_reservation!({"2016-06-03", "2016-06-04"}, [a1, a2], [p1, p3])
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 1+2), p.(p3, 0+2)],
      [a.(a2), p.(p1, 0+2), p.(p3, 0+2)],
      [a.(a3)],
    ]

    # Adding a reservation partially past the end date only counts the relevant
    # days (one in this case)
    insert_ranged_reservation!({"2016-06-30", "2016-07-01"}, [a3], [p1, p2, p3])
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 3), p.(p3, 2)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 0+1), p.(p2, 0+1), p.(p3, 0+1)]
    ]
    
    # The same is true of a reservation that overlaps the beginning.
    insert_ranged_reservation!({"2016-05-28", "2016-06-02"}, [a1], [p1, p2, p3])
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 3+2), p.(p2, 0+2), p.(p3, 2+2)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)]
    ]

    # Unsurprisingly, something not at all overlapping adds nothing.
    insert_ranged_reservation!({"2000-05-28", "2000-06-02"}, [a1], [p1, p2, p3])
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)]
    ]

    # Adding an animal midway through the period does make it show up
    # (There is no notion of an animal's "start date".)
    a4 = insert_old_animal(name: "a4")
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)],
      [a.(a4)]
    ]

    # TODO: Today, it's not clear whether animals are removed from
    # service at the BEGINNING or END of a day. So the following
    # dodges the issue.
    
    # An animal out of service before the period does not appear
    insert_old_animal(name: "a5",
      date_removed_from_service: Ecto.Date.cast!("2000-05-31"))
    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)],
      [a.(a4)]
    ]

    # An animal out of service partway through the period does appear.
    a6 = insert_old_animal(name: "a6",
      date_removed_from_service: Ecto.Date.cast!("2016-06-15"))

    assert S.end_to_end(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)],
      [a.(a4)],
      [a.(a6)]
    ]
  end
end
