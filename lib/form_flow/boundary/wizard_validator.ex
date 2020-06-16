defmodule FormFlow.Boundary.WizardValidator do
  def errors(params \\ %{})

  def errors(params) when is_map(params) do
    data = %{}
    types = %{name: :string, session_id: :string, forms: {:array, :any}}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required(Map.keys(types), message: "is required")
    |> Ecto.Changeset.validate_length(:forms, min: 1, message: "atleast one form is required")
    |> Ecto.Changeset.apply_action(:insert)
    |> errors_response()
  end

  def errors(_), do: {:error, "must be a map"}

  defp errors_response({:error, %Ecto.Changeset{valid?: false} = changeset}) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, _} -> msg end)
      |> Enum.map(fn {key, error} -> {key, Enum.join(error)} end)

    {:error, errors}
  end

  defp errors_response({:ok, _changeset}), do: :ok
end
