defmodule FormFlowTest do
  use ExUnit.Case

  alias FormFlow.Wizard.{Step1, Step2}

  @wizard_params %{forms: [Step1, Step2], name: "Student Registration", session_id: "1"}
  @step_1_params %{first_name: "Michail", last_name: "Gumbs"}

  test "Complete a wizard" do
    session = FormFlow.new_wizard(@wizard_params)

    assert step_1_valid_params(session, @step_1_params) ==
             {true, %{first_name: "Michail", last_name: "Gumbs"}}
  end

  defp step_1_valid_params(session, params) do
    wizard = FormFlow.next_step(session, params)
    step_1 = Enum.at(wizard.steps, 0)
    {step_1.completed?, step_1.changeset.changes}
  end
end
