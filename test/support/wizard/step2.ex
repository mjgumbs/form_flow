defmodule FormFlow.Wizard.Step2 do
  use Ecto.Schema
  import Ecto.Changeset

  @accepted_fields ~w(age)a

  embedded_schema do
    field(:age, :integer)
  end

  def changeset(attrs \\ %{}) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = form, attrs) do
    form
    |> cast(attrs, @accepted_fields)
    |> validate_required(@accepted_fields)
    |> validate_number(:age, greater_than: 10, less_than: 40)
  end
end
