defmodule Eecrit.ViewModelTest do
  use Eecrit.ConnCase
  alias Eecrit.ViewModel, as: S
  
  describe "structural-typing feel of view models" do
    setup do 
      domain_model = make_old_animal(
        name: "jake", procedure_description_kind: "gelding")
      provides(domain_model)
    end
    
    test "view models are typically created from domain model objects", c do
      view_model = S.animal(c.domain_model)

      assert view_model.name == c.domain_model.name # Some fields are present.
      refute Map.has_key?(view_model, :procedure_description_kind) # Some are not.
    end

    test "view models can accept any structure with correct keys", c do
      view_model = S.animal(%{id: 33, name: "jake", field_to_be_ignored: true})

      assert view_model.name == c.domain_model.name
      refute Map.has_key?(view_model, :field_to_be_ignored)
    end

    test "view models will complain loudly if required keys are missing" do
      # Given dutiful TDD around creation of view models, that's not
      # horribly different from a static type check.
      assert_exception ~r/keys must also be given.*\[:name\]/ do 
        S.animal(%{id: 1})
      end
    end

    test "but, as per the pipeline style I like, you can add extra fields", c do
      # ... so another way typing is not nominal
      view_model = S.animal(c.domain_model, use_count: 33)

      assert view_model.name == c.domain_model.name
      assert view_model.use_count == 33
    end

    ## The above doesn't check for failure to provide a use count when one
    ## is expected, etc. But if that were an important enough, a "derived type"
    ## could be created. Mechanism TBD.
  end

  # At the moment, the protocol functions are tested indirectly in view tests.
end
