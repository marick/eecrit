defmodule Eecrit.OldReservationSinkTest do
  use Eecrit.ModelCase
  alias Eecrit.OldReservationSink
  alias Eecrit.OldReservation
  alias Eecrit.OldGroup
  alias Eecrit.OldUse

  test "complete_reservation" do
    animal = insert_old_animal()
    procedure = insert_old_procedure()
    reservation_fields = %OldReservation{course: "vcm333",
                                         first_date: Ecto.Date.cast!("2001-01-01"),
                                         last_date: Ecto.Date.cast!("2012-12-12"),
                                         time_bits: "001"}


    OldReservationSink.insert_new!(reservation_fields, [animal], [procedure])

    use = OldRepo.one(OldUse)
    group = OldRepo.one(OldGroup)
    reservation = OldRepo.one(OldReservation)

    assert use.group_id == group.id
    assert use.animal_id == animal.id
    assert use.procedure_id == procedure.id

    assert group.reservation_id == reservation.id

    assert reservation.course == reservation_fields.course
    assert reservation.first_date == reservation_fields.first_date

    # Check the nesting, just in case
    reservation = reservation |> OldRepo.preload([:animals, :procedures])
    assert reservation.animals == [animal]
    assert reservation.procedures == [procedure]
  end
end
