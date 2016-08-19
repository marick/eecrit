defmodule Eecrit.ViewCase do
  use ExUnit.CaseTemplate

  import RoundingPegs.ExUnit.PhoenixView.Arrange, only: [simulate_browser_routing: 3]

  using do
    quote do
      # The default endpoint for testing (for constructing paths)
      @endpoint Eecrit.Endpoint

      use ShouldI
      use Phoenix.ConnTest
      import Phoenix.View

      import Eecrit.Router.Helpers
      import Eecrit.Test.Makers
      import Eecrit.Test.ConnHelpers
      import Eecrit.Test.ViewHelpers
      import RoundingPegs.ExUnit.CheckStyle

      # TODO: These are going away
      import RoundingPegs.ExUnit.View
      import RoundingPegs.ExUnit.ViewCheckers

      import RoundingPegs.ExUnit.PhoenixView.Arrange
      import RoundingPegs.ExUnit.PhoenixView.Act
      import RoundingPegs.ExUnit.PhoenixView.Assert
    end
  end

  setup tags do
    conn =
      Phoenix.ConnTest.build_conn
      |> Eecrit.Test.Makers.obey_tags(tags)
      |> simulate_browser_routing(Eecrit.Router, Eecrit.Endpoint)
    {:ok, conn: conn}
  end
end
