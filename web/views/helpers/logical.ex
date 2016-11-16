defmodule Eecrit.Helpers.Logical do
  use Eecrit.Web, :view
  use Eecrit.Helpers.Tags
  import Eecrit.Helpers.Resources

  # Define
  
  def path(name, path, extras \\ []) do 
    %{type: :logical_path, name: name, path: path, extras: extras}
  end
  
  def resource(conn, name, module, extras \\ []) do 
    %{type: :logical_resource, conn: conn, name: name, module: module,
      extras: extras}
  end

  def dropdown(name, elements) do
    %{type: :logical_dropdown, name: name, elements: elements}
  end
    
    
  # Render
    
  def to_html(logical, extras \\ [])

  def to_html(logical = %{type: :logical_path}, extras),
    do: link(logical.name, [to: logical.path] ++ extras)

  # TODO: do something with Extras.
  def to_html(logical = %{type: :logical_resource}, _extras),
    do: m_resource_link(logical.conn, logical.name, logical.module)

end
