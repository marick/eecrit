defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    athena = %{ id: 1, 
                name: "Athena", 
                species: "bovine", 
                tags: [ "cow" ],
                int_properties: %{},
                bool_properties: %{"Available" => [true, ""]},
                string_properties: %{ "Primary billing" => ["CSR", ""]},
              }
    
    jake = %{ id: 2, 
              name: "Jake", 
              species: "equine", 
              tags: [ "gelding" ],
              int_properties: %{},
              bool_properties: %{"Available" => [true, ""]},
              string_properties: %{ },
            }
    
    ross = %{ id: 3, 
              name: "ross", 
              species: "equine", 
              tags: [ "stallion", "aggressive" ],
              int_properties: %{},
              bool_properties: %{"Available" => [true, ""]},
              string_properties: %{ "Primary billing" => ["Marick", ""]},
            }
    
    xena = %{ id: 4, 
              name: "Xena", 
              species: "equine", 
              tags: [ "mare", "skittish" ],
              int_properties: %{},
              bool_properties: %{"Available" => [false, "off for the summer"]},
              string_properties: %{ "Primary billing" => ["Marick", ""]},
            }
    
    json conn, %{data: [jake, ross, xena, athena]}
  end
end
