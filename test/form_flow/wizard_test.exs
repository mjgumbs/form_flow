defmodule FormFlow.WizardTest do
  use ExUnit.Case

  alias FormFlow.Core.{Wizard}
  alias FormFlow.Wizard.{Step1, Step2}

  @valid_attrs %{first_name: "Mikey", last_name: "Gumbs"}
  @wizard_params %{forms: [Step1, Step2], name: "Student Registration", session_id: "1"}

  describe "a wizard with two steps" do
    test "a failed step should not move the wizard foward" do
      @wizard_params
      |> Wizard.new()
      |> assert_current_step(1)
      |> Wizard.next()
      |> assert_current_step(1)
    end

    test "a succesfull step should move the wizard forward" do
      @wizard_params
      |> Wizard.new()
      |> assert_current_step(1)
      |> Wizard.next(@valid_attrs)
      |> assert_current_step(2)
    end

    test "a succssfull last step should complete the wizard" do
      @wizard_params
      |> Wizard.new()
      |> assert_status(:in_progress)
      |> assert_current_step(1)
      |> Wizard.next(@valid_attrs)
      |> assert_current_step(2)
      |> assert_status(:in_progress)
      |> Wizard.next(%{age: 19})
      |> assert_current_step(2)
      |> assert_status(:confirmation)
    end

    test "can move back and forth between the steps" do
      @wizard_params
      |> Wizard.new()
      |> assert_current_step(1)
      |> Wizard.back()
      |> assert_current_step(1)
      |> Wizard.next(@valid_attrs)
      |> assert_current_step(2)
      |> Wizard.back()
      |> assert_current_step(1)
      |> Wizard.next()
      |> assert_current_step(2)
    end
  end

  test "new wizard with initial state" do
    @wizard_params
    |> Wizard.new(%{step1: %{first_name: "Michail", last_name: "Gumbs"}, step2: %{age: 30}})
    |> assert_current_step(2)
    |> assert_status(:confrimation)
  end

  defp assert_status(wizard, status) do
    assert wizard.status == status
    wizard
  end

  def assert_current_step(wizard, expected_step) do
    assert wizard.current == expected_step
    wizard
  end
end
