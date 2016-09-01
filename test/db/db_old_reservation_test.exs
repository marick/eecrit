defmodule Eecrit.Db.OldReservationTest do
  use Eecrit.ModelCase
  alias Eecrit.OldReservation

  test "complete_reservation" do
    animal = insert_old_animal()
    procedure = insert_old_procedure()
    reservation_fields = %OldReservation{course: "vcm333",
                                         first_date: Ecto.Date.cast!("2001-01-01"),
                                         last_date: Ecto.Date.cast!("2012-12-12")}


    OldReservation.insert_new!(reservation_fields, [animal], [procedure])

    
    

    # use = %Eecrit.OldUse{animal: animal, procedure: procedure}
    # group = %Eecrit.OldGroup{uses: [use]}
    # reservation = %{ base_reservation | groups: [group]}
    
    # OldRepo.insert!(reservation)

#    Apex.ap(OldRepo.all(Eecrit.OldReservation) |> OldRepo.preload([:animals, :procedures]))
#        Apex.ap OldRepo.all(Eecrit.OldUse)


    # base_reservation
    # |> OldReservation.complete_reservation([animal], [procedure])
    # |> OldRepo.insert!
  end
end
