defmodule FormFlow.Wizard.Step1 do
  use Ecto.Schema
  import Ecto.Changeset

  @accepted_fields ~w(first_name last_name)a

  embedded_schema do
    field(:first_name, :string)
    field(:last_name, :string)
  end

  def changeset(attrs \\ %{}) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = form, attrs) do
    form
    |> cast(attrs, @accepted_fields)
    |> validate_required(@accepted_fields)
  end
end
