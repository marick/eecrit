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
      assert_exception [ExUnit.AssertionError, "No <a> matching /animals"],
        do: S.allows_anchor!(html, :index, @model)
    end

    test "failure case: anchor with bad string" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert_exception ["No :index <a> to /animals", ~r/Animals/],
        do: S.allows_anchor!(html, :index, @model, "Manimals")
    end

    test "success case for action, path, and string" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert S.allows_anchor!(html, :index, @model, "Animals") =~ html
    end

    test "note that the match must be exact" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert_exception ["No :index <a> to /animals", "Animals"],
        do: S.allows_anchor!(html, :index, @model, "Animal")
      html = "<a class='irrelevant' href='/animals'> Animals</a>"
      assert_exception ["No :index <a> to /animals", "Animals"],
        do: S.allows_anchor!(html, :index, @model, "Animals")
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
      assert_exception "Disallowed :new <a> to /animals/new" do 
        html = "<a href='/animals/new'>Animals</a>"
        assert S.disallows_anchor!(html, :new, @model) =~ html
      end

      assert_exception "Disallowed :edit <a> to /animals/1/edit" do 
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
      assert_exception "No :create <form> matching /animals",
        do: S.allows_form!(html, :create, @model)

      # Wrong kind
      html = delete_form
      assert_exception "No :create <form> matching /animals",
        do: S.allows_form!(html, :create, @model)
    end

    test "update" do
      assert S.allows_form!(update_form, :update, [@model, "id"]) =~ update_form
    end

    test "deletion" do
      assert S.allows_form!(delete_form, :delete, [@model, "id"]) =~ delete_form
    end
  end

  describe "disallows_form!" do
    test "creation" do
      two_forms = delete_form <> create_form
      assert S.allows_form!(two_forms, :create, @model) =~ two_forms

      # No form
      html = ""
      assert_exception "No :create <form> matching /animals",
        do: S.allows_form!(html, :create, @model)

      # Wrong kind
      html = delete_form
      assert_exception "No :create <form> matching /animals",
        do: S.allows_form!(html, :create, @model)
    end

    test "update" do
      assert S.allows_form!(update_form, :update, [@model, "id"]) =~ update_form
    end

    test "deletion" do
      assert S.allows_form!(delete_form, :delete, [@model, "id"]) =~ delete_form
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
