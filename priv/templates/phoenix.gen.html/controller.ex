defmodule <%= module %>Controller do
  use <%= base %>.Web, :controller

  alias <%= module %>

  def index(conn, _params) do
    <%= plural %> = Repo.all(<%= alias %>)
    render(conn, "index.html", <%= plural %>: <%= plural %>)
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: <%= alias %>.new_action_changeset)
  end

  def create(conn, %{<%= inspect singular %> => <%= singular %>_params}) do
    changeset = <%= alias %>.create_action_changeset(<%= singular %>_params)

    case Repo.insert(changeset) do
      {:ok, _<%= singular %>} ->
        conn
        |> put_flash(:info, "<%= human %> created successfully.")
        |> redirect(to: <%= singular %>_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)
    render(conn, "show.html", <%= singular %>: <%= singular %>)
  end

  def edit(conn, %{"id" => id}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)
    changeset = <%= alias %>.edit_action_changeset(<%= singular %>)
    render(conn, "edit.html", <%= singular %>: <%= singular %>, changeset: changeset)
  end

  def update(conn, %{"id" => id, <%= inspect singular %> => <%= singular %>_params}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)
    changeset = <%= alias %>.update_action_changeset(<%= singular %>, <%= singular %>_params)

    case Repo.update(changeset) do
      {:ok, <%= singular %>} ->
        conn
        |> put_flash(:info, "<%= human %> updated successfully.")
        |> redirect(to: <%= singular %>_path(conn, :show, <%= singular %>))
      {:error, changeset} ->
        render(conn, "edit.html", <%= singular %>: <%= singular %>, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)
    Repo.delete!(<%= singular %>)

    conn
    |> put_flash(:info, "<%= human %> deleted successfully.")
    |> redirect(to: <%= singular %>_path(conn, :index))
  end
end
