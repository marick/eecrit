defmodule Eecrit.TestHelpers do
  alias Eecrit.Repo
  alias Eecrit.User

  def insert_user(params \\ %{}) do
    suffix = random_string
    defaults = %{display_name: "Test User #{suffix}",
                 login_name: "user#{suffix}@example.com",
                 password: "password"}
    changes = Dict.merge(defaults, params)
    %User{}
    |> User.password_setting_changeset(changes)
    |> Repo.insert!
  end

  defp random_string do
    Base.encode16(:crypto.rand_bytes(8))
  end
end
