defmodule Eecrit.OldProcedureDescriptionView do
  use Eecrit.Web, :view

  def has_description_text?(old_procedure_description) do
    String.slice(old_procedure_description.description, 0, 3) == "TBD"
  end

  def show_link_or_disclaimer(conn, old_procedure_description) do
    if has_description_text?(old_procedure_description) do
      "TBD..."
    else
      link "Show",
          to: old_procedure_description_path(conn, :show, old_procedure_description),
          class: "btn btn-default btn-xs"
    end
  end
end
