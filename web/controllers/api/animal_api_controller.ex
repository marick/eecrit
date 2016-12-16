defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    athena = %{ id: 1, 
                name: "Athena", 
                species: "bovine", 
                tags: [ "cow" ],
                int_properties: %{},
                bool_properties: %{b: [true, "derp"]}
              }
    
    json conn, %{data: [athena]}
  end
end
