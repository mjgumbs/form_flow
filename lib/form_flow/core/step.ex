defmodule FormFlow.Core.Step do
  defstruct key: nil,
            number: nil,
            changeset: nil,
            form: nil

  alias FormFlow.Core.Step

  def new(form, step_num, initial_state) do
    key = determine_key(form)
    changeset = determine_changeset(form, key, initial_state)

    %__MODULE__{
      key: key,
      number: step_num,
      changeset: changeset,
      form: form
    }
  end

  def form_data(%Step{} = step) do
    struct(step.changeset.data, step.changeset.changes)
  end

  def update_changeset(%Step{} = step, changeset = %Ecto.Changeset{}) do
    %{step | changeset: changeset}
  end

  def update_changeset(%Step{} = step, data) do
    attrs = Map.from_struct(data)
    %{step | changeset: step.form.changeset(attrs)}
  end

  defp determine_key(form) do
    to_string(form)
  end

  defp determine_changeset(form, key, initial_state) do
    initial_state
    |> Map.get(key, %{})
    |> form.changeset()
  end
end
