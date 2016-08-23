defmodule RoundingPegs.ExUnit.ViewCheckersTest do
  use Eecrit.ViewCase
  import Eecrit.Router.Helpers
  import RoundingPegs.ExUnit.ViewCheckers.Util

  defp assert_found(search_result), do: assert length(search_result) == 1, inspect(search_result)
  defp refute_found(search_result), do: assert length(search_result) == 0, inspect(search_result)

  having "basic fetchers" do
    describe "finding a path" do
      test "the case with only a resource and an action" do
        assert path_to(Eecrit.OldAnimal, :index, [], []) == "/animals"
        assert path_to(Eecrit.OldAnimal, :new, [], []) == "/animals/new"
      end
      
      test "path taking an argument" do
        assert path_to(Eecrit.OldAnimal, :edit, [1], []) == "/animals/1/edit"
        # As a convenience, a single argument need not be given as a list
        assert path_to(Eecrit.OldAnimal, :edit, 1, []) == "/animals/1/edit"
        # A model may be given instead of the index
        animal = make_old_animal(id: 5)
        assert path_to(Eecrit.OldAnimal, :edit, animal, []) == "/animals/5/edit"
      end

      test "giving params" do
        assert path_to(Eecrit.OldAnimal, :edit, [1], [evil: 3]) ==
          "/animals/1/edit?evil=3"
        # Sadly, it's kludgy when there are no arguments before the params
        assert path_to(Eecrit.OldAnimal, :index, [], [evil: 3, truth: true]) ==
          "/animals?evil=3&truth=true"
        # Probably not better, but you can use nil instead of the explicit empty
        # list
        assert path_to(Eecrit.OldAnimal, :index, nil, [evil: 3, truth: true]) ==
          "/animals?evil=3&truth=true"
      end
        
    end
    test "finding an anchor with text" do
      html = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert_found find_anchor(html, {"Animals", '/animals'})
      refute_found find_anchor(html, {"Animals", '/animals/new'})
      refute_found find_anchor(html, {"Animals to find", '/animals'})
      refute_found find_anchor(html, {"Animal", '/animals'})

      refute_found find_anchor("", {"Animal", '/animals'})
    end

    having "a form" do 
      test "a plain POST can be found by path and action" do
        just_post = "{<form accept-charset='UTF-8' action='/animals' method='post'>
                         stuff
                      </form>"

        assert_found find_form(just_post, "/animals", :create)
        refute_found find_form(just_post, "/", :create)
        refute_found find_form(just_post, "/animalss", :create)
        refute_found find_form(just_post, "/animals", :update)
        refute_found find_form(just_post, "/animals/34", :update)
        refute_found find_form("<input/>", "/", :create)
      end
        
      
      test "a faked method can be found by path and action" do
        has_fake = "<form action='/animals/34' method='post'>
                      <input name='_method' type='hidden' value='delete'>
                      stuff
                    </form>"

        assert_found find_form(has_fake, "/animals/34", :delete)
        refute_found find_form(has_fake, "/animals/34", :update)
        refute_found find_form(has_fake, "/animals/34", :create)
        refute_found find_form(has_fake, "/animals", :create)

        refute_found find_form(has_fake, "/animals/44", :delete)
        refute_found find_form("<input/>", "/", :delete)
      end
    end
  end

  having "a desire to check outgoing paths that are links" do
    test "checking for an index link" do
      selector = {"Animals", Eecrit.OldAnimal}

      ok = "<a class='irrelevant' href='/animals'>Animals</a>"
      assert allows_index!(ok, selector) == ok

      fail_check = fn(html) ->
        assert_raise(ExUnit.AssertionError,
          ~r{No :index link to /animals.* and "Animals"},
          fn -> allows_index!(html, selector) end)
      end

      fail_check.("<form href='/animals'>Animals</a>")
      fail_check.("<a href='/animals/new'>Animals</a>")
      fail_check.("<a href='/animals'>Animal</a>")
      fail_check.("<a href='/animals'>Animalss</a>")
    end

    test "checks can contain params" do
      selector = {"Animals", Eecrit.OldAnimal}

      ok = "<a class='irrelevant' href='/animals?q=true'>Animals</a>"
      assert allows_index!(ok, selector, [], q: true) == ok

      fail_check = fn(html, query) ->
        assert_raise(ExUnit.AssertionError,
          ~r{No :index link to /animals.* and "Animals"},
          fn -> allows_index!(html, selector, [], query) end)
      end

      fail_check.("<a href='/animals'>Animals</a>", [q: 1])
      fail_check.("<a href='/animals?q=1'>Animals</a>", [])
      fail_check.("<a href='/animals?q=1'>Animals</a>", [zz: 1])

      # Note that, for the moment, order matters
      assert allows_index!("<a href='/animals?a=1&b=2'>Animals</a>", selector, [],
        [a: 1, b: 2])
      fail_check.("<a href='/animals?a=1&b=2'>Animals</a>",
        [b: 2, a: 1])
    end

    test "checking for absence of an index link" do
      model = Eecrit.OldAnimal
      assert_raise(ExUnit.AssertionError,
        ~r{Observe the :index link to /animals},
        fn -> disallows_index!("<a href='/animals'>Animals</a>", model) end)

      ok_check = fn(html) -> 
        assert disallows_index!(html, model) == html
      end

      ok_check.("<form href='/animals'>Index</a>")
      ok_check.("<a href='/animals/333'>Show</a>")
    end

    having "the knowledge that all the other functions run almost the same code" do
      test "allows_new" do
        selector = {"New animal", Eecrit.OldAnimal}
        ok = "<a class='irrelevant' href='/animals/new'>New animal</a>"
        assert allows_new!(ok, selector) == ok

        bad = "<a class='irrelevant' href='/animals/33'>New animal</a>"
        assert_raise(ExUnit.AssertionError,
          ~r{No :new link to /animals/new and \"New animal\"},
          fn -> allows_new!(bad, selector) end)
      end

      test "disallows_new" do
        model = Eecrit.OldAnimal

        valid_new = "<a href='/animals/new'>New</a>"
        assert_raise(ExUnit.AssertionError, 
          ~r{Observe the :new link to /animals/new},
          fn -> disallows_new!(valid_new, model) end)

        not_a_new = "<a href='/animals'>Animals</a>"
        assert disallows_new!(not_a_new, model) == not_a_new
      end

      test "remainder" do
        assert allows_edit!("<a href='/animals/1/edit'>Edit</a>",
          {"Edit", Eecrit.OldAnimal}, make_old_animal(id: 1))

        assert allows_show!("<a href='/animals/1?all=true'>Show</a>",
          {"Show", Eecrit.OldAnimal}, make_old_animal(id: 1), all: true)
      end
    end
  end


  having "a desire to check outgoing paths that are form submissions" do
    test "checking existence of forms" do

      valid_form = "<form action='/animals/3' class='link' method='post'>
                       <input name='_method' type='hidden' value='delete'>
                       stuff
                    </form>"
      assert allows_delete!(valid_form, Eecrit.OldAnimal, 3) == valid_form


      different_action = "<form action='/animals/3' class='link' method='post'>
                            <input name='_method' type='hidden' value='delete'>
                            stuff
                          </form>"
      assert_raise(ExUnit.AssertionError,
        ~r{No :delete form for /animals/8888},
        fn -> allows_delete!(different_action, Eecrit.OldAnimal, 8888) end)
      

      create_form = "{<form accept-charset='UTF-8' action='/animals' method='post'>
                        stuff
                      </form>"
      assert allows_create!(create_form, Eecrit.OldAnimal) == create_form
      assert_raise(ExUnit.AssertionError,
        ~r{No :delete form for /animals/8888},
        fn -> allows_delete!(create_form, Eecrit.OldAnimal, 8888) end)

      update_form = "<form accept-charset='UTF-8' action='/animals/3' method='post'>
                       <input name='_method' type='hidden' value='put'>
                       stuff
                     </form>"

      assert allows_update!(update_form, Eecrit.OldAnimal, 3) == update_form

      assert_raise(ExUnit.AssertionError,
        ~r{No :delete form for /animals/8888},
        fn -> allows_delete!(different_action, Eecrit.OldAnimal, 8888) end)
      
      assert_raise(ExUnit.AssertionError,
        ~r{No :create form for /animals},
        fn -> allows_create!("", Eecrit.OldAnimal) end)
    end

    test "checking nonexistence of forms" do
      disallows_delete!("", Eecrit.OldAnimal, 3)

      update_form = "<form accept-charset='UTF-8' action='/animals/3' method='post'>
                       <input name='_method' type='hidden' value='put'>
                       stuff
                     </form>"
      assert_raise(ExUnit.AssertionError,
        ~r{Observe the :update form for /animals/3},
        fn -> disallows_update!(update_form, Eecrit.OldAnimal, 3) end)
      
      disallows_update!(update_form, Eecrit.OldAnimal, 33333)
      disallows_delete!(update_form, Eecrit.OldAnimal, 3)
    end
  end
end
