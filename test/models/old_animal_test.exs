defmodule Eecrit.OldAnimalTest do
  use Eecrit.ModelCase

  alias Eecrit.OldAnimal, as: S

  @valid_date "2012-02-29"
  @invalid_date "2011-01-32"

  @invalid_species "catine"

  @valid_attrs %{kind: "kind", name: "name",
                 procedure_description_kind: hd(S.valid_species)}
  @optional_attrs %{nickname: "nickname", date_removed_from_service: @valid_date}
  @invalid_attrs %{}

  test "a starting changeset" do
    changeset = S.new_action_changeset()
    refute changeset.valid?
  end

  # Creation

  test "changeset with only required attributes" do
    changeset = S.create_action_changeset(@valid_attrs)
    assert changeset.valid?
    assert changeset.changes == @valid_attrs
  end

  test "changeset with all attributes" do
    attrs = Map.merge(@valid_attrs, @optional_attrs)
    changeset = S.create_action_changeset(attrs)
    assert changeset.valid?
    assert changeset.changes.date_removed_from_service == Ecto.Date.cast!(@valid_date)
  end

  test "an invalid changeset: bad date" do
    attrs = Map.put(@valid_attrs, :date_removed_from_service, @invalid_date)
    changeset = S.create_action_changeset(attrs)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :date_removed_from_service)
  end

  test "an invalid changeset: bad species" do
    attrs = Map.put(@valid_attrs, :procedure_description_kind, @invalid_species)
    changeset = S.create_action_changeset(attrs)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :procedure_description_kind)
  end

  test "a blank date is *not* an invalid changeset: null is allowed" do
    attrs = Map.put(@valid_attrs, :date_removed_from_service, "")
    changeset = S.create_action_changeset(attrs)
    assert changeset.valid?
    assert changeset.changes[:date_removed_from_service] == nil
  end

  test "the notion of 'already out of service'" do
    today = ~D[2016-08-03]
    e_yesterday = Ecto.Date.cast!(~D[2016-08-02])
    e_today = Ecto.Date.cast!(today)
    e_tomorrow = Ecto.Date.cast!(~D[2016-08-04])
    
    out_before_today = make_old_animal(date_removed_from_service: e_yesterday)
    out_today = make_old_animal(date_removed_from_service: e_today)
    out_after_today = make_old_animal(date_removed_from_service: e_tomorrow)
    assert S.already_out_of_service?(out_before_today, today)
    assert S.already_out_of_service?(out_today, today)
    refute S.already_out_of_service?(out_after_today, today)

    # Really uses a default argument for today
    animal = make_old_animal(date_removed_from_service: Ecto.Date.cast!("2000-01-01"))
    assert S.already_out_of_service?(animal)
  end

  test "sorting a list of animals in a pleasing way" do
    animals = [make_old_animal(name: "AM"),
               make_old_animal(name: "aa"),
               make_old_animal(name: "K"),
               make_old_animal(name: "m"),
               make_old_animal(name: "1")]
    assert S.alphabetical_names(animals) == ["1", "aa", "AM", "K", "m"]
  end

  describe "calculating use-days" do 
    @a1 %{id: "a1"}
    @a2 %{id: "a2"}
    @a3 %{id: "a3"}
    @p1 %{id: "p1"}
    @p2 %{id: "p2"}
    @p3 %{id: "p3"}

    @single_day {Ecto.Date.cast!("2012-12-12"), Ecto.Date.cast!("2012-12-12")}
    @another_single_day {Ecto.Date.cast!("2012-12-13"), Ecto.Date.cast!("2012-12-13")}
    @ten_days {Ecto.Date.cast!("2012-11-01"), Ecto.Date.cast!("2012-11-10")}

    test "flattening these composite results" do
      one = %{animals: [@a1, @a2], procedures: [@p1, @p2], date_range: @ten_days}
      assert S.flatten_condensed_reservations([one]) ==
        [{@a1, @p1, 10},
         {@a1, @p2, 10},
         {@a2, @p1, 10},
         {@a2, @p2, 10}]
    end

    test "how the reduce step is started" do
      assert S.reduce_step({@a1, @p1, 3}, %{}) == %{@a1 => %{@p1 => 3}}
    end

    test "adding a new animal" do
      already = %{@a1 => %{@p1 => 3}}
      assert S.reduce_step({@a2, @p1, 5}, already) ==
       Map.merge(already, %{@a2 => %{@p1 => 5}})
    end

    test "adding a new procedure to an existing animal" do
      already = %{@a1 => %{@p1 => 3}}
      assert S.reduce_step({@a1, @p2, 5}, already) ==
       %{@a1 => %{@p1 => 3, @p2 => 5}}
    end      

    test "updating the count of an existing animal/procedure pair" do
      already = %{@a1 => %{@p1 => 3}}
      assert S.reduce_step({@a1, @p1, 5}, already) == %{@a1 => %{@p1 => 8}}
    end      

    test "final calculation" do
      raw = [%{animals: [@a1, @a2], procedures: [@p1, @p2], date_range: @single_day},
             %{animals: [@a2, @a3], procedures: [@p2, @p3], date_range: @another_single_day},
             %{animals: [@a2], procedures: [@p1], date_range: @ten_days}
            ]

      expected = %{@a1 => %{@p1 => 1,  @p2 => 1,        },
                   @a2 => %{@p1 => 11, @p2 => 2, @p3 => 1},
                   @a3 => %{           @p2 => 1, @p3 => 1}}
      assert S.use_days(raw) == expected
    end
  end
end
