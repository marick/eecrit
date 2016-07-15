defmodule Eecrit.TestHelpers do
  alias Eecrit.Repo
  alias Eecrit.User
  import ExUnit.Assertions
#  alias Eecrit.Permissions

  def insert_user(overrides \\ %{}) do
    suffix = random_string
    defaults = %{display_name: "Test User #{suffix}",
                 login_name: "user#{suffix}@example.com",
                 password: "password"}
    params = Dict.merge(defaults, overrides)
    %User{}
    |> User.password_setting_changeset(params)
    |> Repo.insert!
  end

  # def insert_permissions(overrides \\ %{}) do 
  #   defaults = %{tag: "test permissions",
  #                is_superuser: false,
  #                is_admin: false}
  #   params = Dict.merge(defaults, overrides)

  #   Permissions.fresh_changeset(params) |> Repo.insert!
  # end

  defp random_string do
    Base.encode16(:crypto.rand_bytes(8))
  end

  # Use of assert in following is a quick and dirty way to get good error messages.
  # It's still used with the assert macro in the test, just for consistency.
  
  def renders_template(conn, which) do
    assert conn.private.phoenix_template == which
    true
  end
  
end
