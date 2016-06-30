defmodule Eecrit.UserView do
  use Eecrit.Web, :view
  alias Eecrit.User

  def first_name(%User{display_name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
