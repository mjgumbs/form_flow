defmodule FormFlow do
  alias FormFlow.{
    Boundary.WizardSession,
    Boundary.WizardValidator
  }

  def new_wizard(params) do
    with :ok <- WizardValidator.errors(params),
         {:ok, _} <- WizardSession.new(params) do
      {params.name, params.session_id}
    end
  end

  def wizard_state(name) do
    WizardSession.get_state(name)
  end

  def next_step(session, params) do
    WizardSession.next_step(session, params)
  end
end
