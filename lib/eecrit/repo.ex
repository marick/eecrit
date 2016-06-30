defmodule Eecrit.Repo do
  # use Ecto.Repo, otp_app: :eecrit

  def all(Eecrit.User) do
    [%Eecrit.User{id: 1, display_name: "Brian Marick",
                  login_name: "marick@critter4us.com", password: "password",
                  organizational_scope: "*"},
     %Eecrit.User{id: 2, display_name: "Cindy Pruitt", 
                  login_name: "cindy@critter4us.com", password: "password",
                  organizational_scope: "uicvm-aacup"}
     ]
  end

  def all(_module), do: []

  def get(module, id) do
    Enum.find all(module), fn map -> map.id == id end
  end

  def get_by(module, params) do
    Enum.find all(module), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end
  end
  
end
