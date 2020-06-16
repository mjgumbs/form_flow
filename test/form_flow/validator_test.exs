defmodule FormFlow.Boundary.WizardValidatorTest do
  use ExUnit.Case
  alias FormFlow.Boundary.WizardValidator
  alias FormFlow.Wizard.Step1

  test "wizard fields with only session_id, name and forms is valid" do
    fields = %{session_id: "123", name: "registration", forms: [Step1]}
    assert WizardValidator.errors(fields) == :ok
  end

  test "wizard fields without session_id, name and forms is invalid" do
    expected = {:error, [forms: "is required", name: "is required", session_id: "is required"]}
    assert WizardValidator.errors() == expected
  end

  test "wizard fields without atleast one form is invalid" do
    fields = %{session_id: "123", name: "registration", forms: []}
    expected = {:error, [forms: "atleast one form is required"]}
    assert WizardValidator.errors(fields) == expected
  end

  test "wizard fields of the wrong type is invalid" do
    assert WizardValidator.errors("invalid") == {:error, "must be a map"}
  end
end
