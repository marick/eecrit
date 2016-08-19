defmodule Eecrit.ViewCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ShouldI
      use Phoenix.ConnTest
      import Phoenix.View

      import Eecrit.Router.Helpers
      import Eecrit.Test.Makers
      import Eecrit.Test.ConnHelpers
      import Eecrit.Test.ViewHelpers
      import RoundingPegs.ExUnit.CheckStyle
      import RoundingPegs.ExUnit.View
      import RoundingPegs.ExUnit.ViewCheckers
      
      # The default endpoint for testing (for constructing paths)
      @endpoint Eecrit.Endpoint
    end
  end

  setup tags do
    conn =
      Phoenix.ConnTest.build_conn()
      |> Eecrit.Test.Makers.obey_tags(tags)
      |> RoundingPegs.ExUnit.View.simulate_routing
    {:ok, conn: conn}
  end
end
