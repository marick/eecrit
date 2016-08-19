defmodule Eecrit.PageView do
  use Eecrit.Web, :view
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.User
  alias Eecrit.Organization
  alias Eecrit.AbilityGroup
  use Eecrit.TagHelpers

  def commands(conn) do
    button_groups = [
      # No user
      [m_no_user_button(conn, "Please Log In", session_path(conn, :new)),
      ],

      # Daily admin work
      [m_resource_button(conn, "Work With Animals", OldAnimal),
       m_resource_button(conn, "Work With Procedures", OldProcedure),
      ],

      # Rarer work for all-organization admin.
      [m_resource_button(conn, "Users", User),
       m_resource_button(conn, "Organizations", Organization),
       m_resource_button(conn, "Ability Groups", AbilityGroup),
      ],
    ]

    Enum.map(button_groups, &decorate_button_group/1)
  end

  def decorate_button_group(button_group) do
    button_group
    |> add_space
    |> wrap_in_section
  end

  def wrap_in_section(iolist) do
    m_surround_content(
      tag(:hr),
      p(iolist, class: "lead"),
      [])
  end
end
