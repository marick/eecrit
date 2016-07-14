# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Eecrit.Repo.insert!(%Eecrit.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Code.load_file "priv/repo/util.exs"
alias Eecrit.U

U.fresh_start!

# Permissions
U.add_permissions! tag: "superuser",
  in_all_organizations: true, can_add_users: true, can_see_admin_page: true
U.add_permissions! tag: "admin",
  can_add_users: true, can_see_admin_page: true

# Organizations
U.add_org! short_name: "test org", full_name: "Critter4Us Test Organization"
U.add_org! short_name: "uiuc/aacup",
           full_name: "University of Illinois Agricultural Animal Care and Use"

