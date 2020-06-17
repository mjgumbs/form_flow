defmodule FormFlowTest do
  use ExUnit.Case

  alias FormFlow.Wizard.{Step1, Step2}

  @wizard_params %{forms: [Step1, Step2], name: "Student Registration", session_id: "1"}
  @step_1_params %{first_name: "Michail", last_name: "Gumbs"}
  @step_2_params %{age: 30}

  test "Complete a wizard" do
    session = FormFlow.new_wizard(@wizard_params)

    assert step_with_valid_params(session, @step_1_params) ==
             {true, %{first_name: "Michail", last_name: "Gumbs"}}

    assert step_with_valid_params(session, @step_2_params, 2) == {true, %{age: 30}}

    wizrard_state = FormFlow.wizard_state(session)

    assert wizrard_state.finished? == true
  end

  defp step_with_valid_params(session, params, step_num \\ 1) do
    step_index = step_num - 1
    wizard = FormFlow.next_step(session, params)
    step = Enum.at(wizard.steps, step_index)
    {step.completed?, step.changeset.changes}
  end
end
