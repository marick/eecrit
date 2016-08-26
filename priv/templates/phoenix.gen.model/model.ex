defmodule <%= module %> do
  use <%= base %>.Web, :model
  use <%= base %>.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_superuser  # You will want to change this.
  alias <%= module %>

  schema <%= inspect plural %> do
<%= for {k, _} <- attrs do %>    field <%= inspect k %>, <%= inspect types[k] %><%= schema_defaults[k] %>
<% end %><%= for {k, _, m, _} <- assocs do %>    belongs_to <%= inspect k %>, <%= m %>
<% end %>
    timestamps()
  end

  @visible_fields []    # You will want to change this
  @fields_always_required @visible_fields

  defp changeset(struct, params) do
    struct
    |> cast(params, @visible_fields)
    |> validate_required(@fields_always_required)
  end
end
