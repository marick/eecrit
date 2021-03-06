defmodule Eecrit.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint Eecrit.Endpoint

      use Phoenix.ConnTest
      
      alias Eecrit.Repo
      alias Eecrit.OldRepo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Eecrit.Router.Helpers
      import Eecrit.Test.Makers

      use RoundingPegs.ExUnit
      import RoundingPegs.ExUnit.Conn.Assert
      import RoundingPegs.ExUnit.PhoenixView.Assert
    end
  end

  setup context do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Eecrit.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Eecrit.OldRepo)

    unless context[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Eecrit.Repo, {:shared, self()})
      Ecto.Adapters.SQL.Sandbox.mode(Eecrit.OldRepo, {:shared, self()})
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Eecrit.Test.Makers.obey_tags(context)

    ShouldI.assign context, conn: conn
  end
end
