defmodule Eecrit.ModelDefaults do
  defmacro __using__(model: model) do
    quote do
      def new_action_changeset do   # Start empty
        changeset(struct(unquote(model)), %{})
      end
      
      def create_action_changeset(params) do
        changeset(struct(unquote(model)), params)
      end
      
      def edit_action_changeset(current_version) do
        changeset(current_version, %{})
      end
      
      def update_action_changeset(current_version, updates) do
        changeset(current_version, updates)
      end

      defoverridable [new_action_changeset: 0,
                      create_action_changeset: 1,
                      edit_action_changeset: 1,
                      update_action_changeset: 2]
    end
  end
end
