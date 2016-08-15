defmodule Eecrit.ViewCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ShouldI
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import Phoenix.View

      import Eecrit.Router.Helpers
      import Eecrit.Test.Makers
      import Eecrit.Test.ConnHelpers
      import Eecrit.Test.ViewHelpers

      # The default endpoint for testing
      @endpoint Eecrit.Endpoint
    end
  end

  setup tags do
    conn =
      Phoenix.ConnTest.build_conn()
      |> Eecrit.Test.Makers.obey_tags(tags)
      |> Eecrit.Test.ViewHelpers.simulate_routing
    {:ok, conn: conn}
  end
end
