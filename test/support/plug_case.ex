defmodule Eecrit.PlugCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  If the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @opts Eecrit.Router.init([])

      # Import conveniences for testing with plugs
      use Phoenix.ConnTest

      alias Eecrit.Repo
      alias Eecrit.OldRepo
      import Eecrit.Test.Makers
      alias Eecrit.Test.PlugHelpers
      alias Plug.Conn
      alias Phoenix.ConnTest 

      use RoundingPegs.ExUnit
      alias RoundingPegs.ExUnit.Conn.Arrange
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Eecrit.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Eecrit.OldRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Eecrit.Repo, {:shared, self()})
      Ecto.Adapters.SQL.Sandbox.mode(Eecrit.OldRepo, {:shared, self()})
    end

    conn =
      Plug.Test.conn(:get, "/")
      |> Eecrit.Test.Makers.obey_tags(tags)

    {:ok, conn: conn}
  end
end
