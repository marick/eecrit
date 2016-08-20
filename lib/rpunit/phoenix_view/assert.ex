defmodule RoundingPegs.ExUnit.PhoenixView.Assert do
  @moduledoc """
  This module mostly contains checker-style assertions that are
  used to query views about links and forms generated from path helpers.
  They are generally used in this form:

    html
    |> allows_index!(Eecrit.Animal, "View all animals")
    |> disallows_update!(%Eecrit.Animal{...})
    |> allows_create!({Eecrit.Animal, 1})
  """
end
