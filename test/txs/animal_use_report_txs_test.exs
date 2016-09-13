defmodule Eecrit.AnimalUseReportTxsTest do
  use Eecrit.ConnCase
  alias Eecrit.AnimalUseReportTxs.P, as: P
  alias Eecrit.AnimalUseReportTxs, as: S
  
  ### Privates

  setup do
    a1 = make_old_animal(id: 11, name: "a1")
    a2 = make_old_animal(id: 22, name: "a2")
    a3 = make_old_animal(id: 33, name: "a3")
    animals = [a1, a2, a3]
    
    p1 = make_old_animal(id: 111, name: "p1")
    p2 = make_old_animal(id: 222, name: "p2")
    p3 = make_old_animal(id: 333, name: "p3")
    procedures = [p1, p2, p3]
    provides([a1, a2, a3, animals, p1, p2, p3, procedures])
  end

  test "aggregate_use_counts" do
    uses = [{11, 111, 1},
            {11, 222, 2},
            {11, 111, 3},   # note animal/procedure key is same as above
            {22, 333, 4},
           ]
    expected = [{11, 111, 4},
                {11, 222, 2},
                {22, 333, 4},
               ]
    actual = P.sum_counts_of_duplicate_animal_procedure_pairs(uses)
    assert_same_elements(actual, expected)
  end

  test "grouping procedure ids under the animals they belong to" do
    input = [{11, 111, 11},
             {11, 222, 12},
             {22, 222, 22}]
    animal_ids = [11, 22, 33]  # Note that 33 has no uses in above

    expected = [[11, {222, 12}, {111, 11}],
                [22, {222, 22}],
                [33]]
    
    actual = P.create_list_of_lists(input, animal_ids)
    assert_same_elements(actual, expected)
  end

  test "convert ids to models", c do
    list_of_lists = [ [c.a1.id, {c.p1.id, 1}, {c.p2.id, 2}],
                      [c.a2.id, {c.p1.id, 3}, {c.p3.id, 4}],
                      [c.a3.id]]

    expected = [ [c.a1, {c.p1, 1}, {c.p2, 2}],
                 [c.a2, {c.p1, 3}, {c.p3, 4}],
                 [c.a3] ]

    actual = P.convert_ids_to_models(list_of_lists, c.animals, c.procedures)
    assert actual == expected
  end

  test "convert models to model views", c do
    list_of_lists = [ [c.a1, {c.p1, 1}, {c.p2, 2}],
                      [c.a2, {c.p1, 3}, {c.p3, 4}],
                      [c.a3] ]
    # Note that models has all sorts of extra fields to strip off.
    assert Map.has_key?(c.a1, :nickname)
    assert Map.has_key?(c.p1, :date_removed_from_service)

    expected = [ [ %{id: c.a1.id, name: c.a1.name},
                     %{id: c.p1.id, name: c.p1.name, use_count: 1},
                     %{id: c.p2.id, name: c.p2.name, use_count: 2}],
                 [ %{id: c.a2.id, name: c.a2.name},
                     %{id: c.p1.id, name: c.p1.name, use_count: 3},
                     %{id: c.p3.id, name: c.p3.name, use_count: 4}],
                 [ %{id: c.a3.id, name: c.a3.name}]
               ]

    actual = P.convert_models_to_model_views(list_of_lists)
    assert actual == expected
  end
        
  test "sort everything by name" do
    list_of_lists = [ [ %{name: "an-Z"}, %{name: "pr-F"}, %{name: "pr-a"}],
                      [ %{name: "an-M2"}, %{name: "pr-b"}, %{name: "pr-A"}],
                      [ %{name: "an-m1"} ]]
                      
    expected = [[ %{name: "an-m1"} ],
                [ %{name: "an-M2"}, %{name: "pr-A"}, %{name: "pr-b"}],
                [ %{name: "an-Z"}, %{name: "pr-a"}, %{name: "pr-F"}]]

    actual = P.two_level_sort(list_of_lists)
    assert actual == expected
  end
    

  test "complete flow from in-memory models to view model", c do
    uses = [{c.a1.id, c.p1.id, 1},
            {c.a2.id, c.p1.id, 1},
            {c.a1.id, c.p2.id, 2},
            {c.a2.id, c.p3.id, 4},
            {c.a2.id, c.p1.id, 2},  # duplicate animal-procedure pair.
           ]
    
    expected = 
      [ [%{id: c.a1.id, name: c.a1.name},
           %{id: c.p1.id, name: c.p1.name, use_count: 1},
           %{id: c.p2.id, name: c.p2.name, use_count: 2}],
        [%{id: c.a2.id, name: c.a2.name},
           %{id: c.p1.id, name: c.p1.name, use_count: 3},
           %{id: c.p3.id, name: c.p3.name, use_count: 4}],
        [%{id: c.a3.id, name: c.a3.name}],
      ]
    actual = P.view_model(uses, c.animals, c.procedures)
    assert actual == expected
  end


  ### Publics

  test "including database lookup" do
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
    assert S.run(one_month) == [
      [a.(a1), p.(p1, 1)],
      [a.(a2)],
      [a.(a3)],
    ]

    insert_ranged_reservation!({"2016-06-03", "2016-06-04"}, [a1, a2], [p1, p3])
    assert S.run(one_month) == [
      [a.(a1), p.(p1, 1+2), p.(p3, 0+2)],
      [a.(a2), p.(p1, 0+2), p.(p3, 0+2)],
      [a.(a3)],
    ]

    # Adding a reservation partially past the end date only counts the relevant
    # days (one in this case)
    insert_ranged_reservation!({"2016-06-30", "2016-07-01"}, [a3], [p1, p2, p3])
    assert S.run(one_month) == [
      [a.(a1), p.(p1, 3), p.(p3, 2)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 0+1), p.(p2, 0+1), p.(p3, 0+1)]
    ]
    
    # The same is true of a reservation that overlaps the beginning.
    insert_ranged_reservation!({"2016-05-28", "2016-06-02"}, [a1], [p1, p2, p3])
    assert S.run(one_month) == [
      [a.(a1), p.(p1, 3+2), p.(p2, 0+2), p.(p3, 2+2)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)]
    ]

    # Unsurprisingly, something not at all overlapping adds nothing.
    insert_ranged_reservation!({"2000-05-28", "2000-06-02"}, [a1], [p1, p2, p3])
    assert S.run(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)]
    ]

    # Adding an animal midway through the period does make it show up
    # (There is no notion of an animal's "start date".)
    a4 = insert_old_animal(name: "a4")
    assert S.run(one_month) == [
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
    assert S.run(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)],
      [a.(a4)]
    ]

    # An animal out of service partway through the period does appear.
    a6 = insert_old_animal(name: "a6",
      date_removed_from_service: Ecto.Date.cast!("2016-06-15"))

    assert S.run(one_month) == [
      [a.(a1), p.(p1, 5), p.(p2, 2), p.(p3, 4)],
      [a.(a2), p.(p1, 2), p.(p3, 2)],
      [a.(a3), p.(p1, 1), p.(p2, 1), p.(p3, 1)],
      [a.(a4)],
      [a.(a6)]
    ]
  end
end
