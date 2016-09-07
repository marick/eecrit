defmodule Eecrit.ReportControllerTest do
  use Eecrit.ConnCase
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.ReportController, as: S

  alias Eecrit.Report
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

  ####

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

end
