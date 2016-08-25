defmodule RoundingPegs.ExUnit.PhoenixView.AssertTest do
  use RoundingPegs.ExUnit.Case
  alias RoundingPegs.ExUnit.PhoenixView.Assert, as: S
  require Eecrit.Router.Helpers

  @model Eecrit.OldAnimal

  describe "allows_anchor!" do 
    test "the simple success case" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert S.allows_anchor!(html, :index, @model) =~ html
    end

    test "failure case: no anchor" do
      html = ""
      assert_exception [ExUnit.AssertionError, "Found no <a> matching /animals"],
        do: S.allows_anchor!(html, :index, @model)
    end

    test "failure case: anchor with bad string" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert_exception ["No :index for /animals", ~r/Animals/],
        do: S.allows_anchor!(html, :index, @model, text: "Manimals")
    end

    test "success case for action, path, and string" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert S.allows_anchor!(html, :index, @model, text: "Animals") =~ html
    end

    test "note that the match must be exact" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert_exception ["No :index for /animals", "Animals"],
        do: S.allows_anchor!(html, :index, @model, text: "Animal")
      html = "<a class='irrelevant' href='/animals'> Animals</a>"
      assert_exception ["No :index for /animals", "Animals"],
        do: S.allows_anchor!(html, :index, @model, text: "Animals")
    end
  end

  describe "disallows_anchor!" do
    test "a simple success case: no anchor with that path" do
      html = "<a href='/NOT_animals'>Animals</a>"
      assert S.disallows_anchor!(html, :index, @model) =~ html
    end

    test "a simple success case: different path index" do
      html = "<a href='/animals/new'>Animals</a>"
      assert S.disallows_anchor!(html, :index, @model) =~ html
    end

    test "the failue case" do
      assert_exception "Found disallowed :new <a> to /animals/new" do 
        html = "<a href='/animals/new'>Animals</a>"
        assert S.disallows_anchor!(html, :new, @model) =~ html
      end

      assert_exception "Found disallowed :edit <a> to /animals/1/edit" do 
        html = "<a href='/animals/1/edit'>Animals</a>"
        assert S.disallows_anchor!(html, :edit, [@model, 1]) =~ html
      end
    end
  end

  
  def create_form,
    do: "<form accept-charset='UTF-8' action='/animals' method='post'>
            stuff
         </form>"

  def update_form,
    do: "<form action='/animals/id' method='post'>
           <input name='_method' type='hidden' value='put'>
              stuff
         </form>"

  def delete_form,
    do: "<form action='/animals/id' method='post'>
           <input name='_method' type='hidden' value='delete'>
           stuff
         </form>"


  describe "allows_form!" do
    test "creation" do
      two_forms = delete_form <> create_form
      assert S.allows_form!(two_forms, :create, @model) =~ two_forms
      
      # No form
      html = ""
      assert_exception "Found no :create <form> matching /animals",
        do: S.allows_form!(html, :create, @model)
      
      # Wrong kind
      html = delete_form
      assert_exception "Found no :create <form> matching /animals",
        do: S.allows_form!(html, :create, @model)
    end

    test "update" do
      assert S.allows_form!(update_form, :update, [@model, "id"]) =~ update_form

      # Wrong kind
      html = create_form
      assert_exception "Found no :update <form> matching /animals/1",
        do: S.allows_form!(html, :update, [@model, 1])
    end

    test "deletion" do
      assert S.allows_form!(delete_form, :delete, [@model, "id"]) =~ delete_form

      # Wrong kind
      html = update_form
      assert_exception "Found no :delete <form> matching /animals/1",
        do: S.allows_form!(html, :delete, [@model, 1])
    end
  end

  describe "disallows_form!" do
    test "creation" do
      html = delete_form <> update_form
      assert S.disallows_form!(html, :create, @model) == html

      html = delete_form <> create_form
      assert_exception "Found disallowed :create <form> for /animals",
        do: S.disallows_form!(html, :create, @model)
    end

    test "update" do
      html = update_form

      # Note different id
      assert S.disallows_form!(html, :update, [@model, "diff_id"]) == html

      assert_exception "Found disallowed :update <form> for /animals/id",
        do: S.disallows_form!(html, :update, [@model, "id"])
    end

    test "deletion" do
      html = ""
      assert S.disallows_form!(html, :delete, [@model, "id"]) == html

      html = update_form
      assert S.disallows_form!(html, :delete, [@model, "id"]) == html

      html = update_form <> delete_form
      assert_exception "Found disallowed :delete <form> for /animals/id",
        do: S.disallows_form!(html, :delete, [@model, "id"])
    end
  end

  describe "disallows_any_form!" do
    test "Only a model is allowed as the shorthand argument" do
      assert_exception "no args allowed",
        do: S.disallows_any_form!("", :delete, [@model, "id"])
    end
    
    test "creation is no different than `disallows_form!`" do
      html = delete_form <> update_form
      assert S.disallows_any_form!(html, :create, @model) == html
      
      html = delete_form <> create_form
      assert_exception "Found disallowed :create <form> for /animals",
        do: S.disallows_any_form!(html, :create, @model)

      html = delete_form <> create_form
      assert_exception "Found disallowed :create <form> for /animals",
        do: S.disallows_any_form!(html, :create, :old_animal_path)
    end

    test "update" do
      # Catches any animal update, no matter the target
      html = 
         "<form action='/animals/id2' method='post'>
            <input name='_method' type='hidden' value='put'>
               stuff
          </form>"

      assert_exception "Found disallowed :update <form> for /animals...",
        do: S.disallows_any_form!(html, :update, @model)

      # Can also use the path function
      assert_exception "Found disallowed :update <form> for /animals...",
        do: S.disallows_any_form!(html, :update, :old_animal_path)

      # Will not object to a delete function - just update
      html = 
         "<form action='/animals/id2' method='post'>
            <input name='_method' type='hidden' value='delete'>
               stuff
          </form>"
      S.disallows_any_form!(html, :update, :old_animal_path) =~ html
    end
    
    test "deletion" do
      # Catches any animal delete, no matter the target
      html = 
         "<form action='/animals/id2' method='post'>
            <input name='_method' type='hidden' value='delete'>
               stuff
          </form>"

      assert_exception "Found disallowed :delete <form> for /animals...",
        do: S.disallows_any_form!(html, :delete, @model)

      # Can also use the path function
      assert_exception "Found disallowed :delete <form> for /animals...",
        do: S.disallows_any_form!(html, :delete, :old_animal_path)

      # Will not object to an update function - just delete
      html = 
         "<form action='/animals/id2' method='post'>
            <input name='_method' type='hidden' value='put'>
               stuff
          </form>"
      S.disallows_any_form!(html, :delete, :old_animal_path) =~ html
    end
  end
    
  test "querying a form for the rest verb - allowing standard kludge" do
    assert S.has_true_rest_verb?(create_form, "post")
    assert S.has_true_rest_verb?(update_form, "put")
    assert S.has_true_rest_verb?(delete_form, "delete")
    
    refute S.has_true_rest_verb?(create_form, "put")
    refute S.has_true_rest_verb?(update_form, "delete")
    refute S.has_true_rest_verb?(delete_form, "post")
  end
end
