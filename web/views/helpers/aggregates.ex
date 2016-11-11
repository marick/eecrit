defmodule Eecrit.Helpers.Aggregates do
  use Eecrit.Helpers.Tags

  def ul_list(class, do: items) do
    m_ul class: class do
      Enum.map items, &m_li/1
    end
  end

end
