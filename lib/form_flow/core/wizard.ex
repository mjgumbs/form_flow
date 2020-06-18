defmodule FormFlow.Core.Wizard do
  defstruct name: "",
            session_id: "",
            steps: [],
            number_of_steps: nil,
            current: 0,
            status: :in_progress

  alias FormFlow.Core.{Step, Wizard}

  @doc """
  Creates a new wizard passing a list of forms and any initial data
  """
  def new(params, initial_state \\ %{}) do
    steps =
      params.forms
      |> List.wrap()
      |> build_steps(initial_state)

    wizard = %Wizard{
      name: params.name,
      session_id: params.session_id,
      steps: steps,
      number_of_steps: length(steps),
      current: determine_initial_current_step(steps)
    }

    update_status(wizard)
  end

  @doc """
  Attempts to proccess the current step and go to the next step
  """
  def next(wizard, params \\ %{}) do
    wizard
    |> get_current()
    |> process_current_step(params)
    |> handle_process_response(wizard)
  end

  @doc """
  Goes to the previous step
  """
  def back(wizard) do
    wizard
    |> update_current_step(:down)
    |> update_status()
  end

  @doc """
  Returns the public state of the wizard
  """
  def state(wizard) do
    steps = Enum.map(wizard.steps, &map_wizard_state_steps(&1, wizard.current))

    %{
      steps: steps,
      status: wizard.status,
      current: Enum.at(steps, wizard.current - 1),
      number_of_steps: wizard.number_of_steps
    }
  end

  def current(wizard), do: get_current(wizard)

  defp build_steps(forms, initial_state) do
    forms
    |> Enum.with_index(1)
    |> Enum.reduce([], &add_step(&1, &2, initial_state))
    |> Enum.reverse()
  end

  defp add_step({form, step}, steps, initial_state) do
    [Step.new(form, step, initial_state) | steps]
  end

  defp determine_initial_current_step(steps) do
    Enum.reduce_while(steps, 0, fn step, acc ->
      case step.changeset.valid? do
        true ->
          {:cont, acc + 1}

        _ ->
          {:halt, step.number}
      end
    end)
  end

  defp get_current(wizard) do
    current_index = wizard.current - 1
    Enum.at(wizard.steps, current_index)
  end

  defp process_current_step(step, params) do
    step
    |> Step.form_data()
    |> step.form.changeset(params)
    |> Ecto.Changeset.apply_action(:update)
    |> update_step_changeset(step)
  end

  defp update_step_changeset({_, changeset}, step) do
    Step.update_changeset(step, changeset)
  end

  defp handle_process_response(%Step{} = step, wizard) do
    current_step_index = step.number - 1

    wizard =
      wizard
      |> Map.update!(:steps, &replace_step_at_index(&1, current_step_index, step))
      |> update_status()

    case step.changeset do
      %Ecto.Changeset{valid?: false} ->
        wizard

      %Ecto.Changeset{} ->
        wizard
        |> update_current_step(:up)
    end
  end

  defp replace_step_at_index(steps, index, new_step) do
    List.replace_at(steps, index, new_step)
  end

  defp update_current_step(wizard, :up) do
    new_step_number = wizard.current + 1

    if new_step_number > wizard.number_of_steps do
      wizard
    else
      Map.put(wizard, :current, new_step_number)
    end
  end

  defp update_current_step(wizard, :down) do
    new_step_number = wizard.current - 1

    if new_step_number < 1 do
      wizard
    else
      Map.put(wizard, :current, new_step_number)
    end
  end

  defp update_status(wizard) do
    steps_finished = calculate_number_of_finished_steps(wizard.steps)
    match = steps_finished - wizard.number_of_steps + wizard.current == wizard.number_of_steps
    update_status(wizard, wizard.status, match)
  end

  defp update_status(wizard, _, false) do
    Map.put(wizard, :status, :in_progress)
  end

  defp update_status(wizard, :in_progress, true) do
    Map.put(wizard, :status, :confirmation)
  end

  defp update_status(wizard, :confirmation, true) do
    Map.put(wizard, :status, :completed)
  end

  defp update_status(wizard, _, _) do
    wizard
  end

  defp calculate_number_of_finished_steps(steps) do
    steps
    |> Enum.filter(&(&1.changeset.valid? == true))
    |> length()
  end

  defp map_wizard_state_steps(step, current_step) do
    %{
      key: step.key,
      name: step.name,
      changeset: step.changeset,
      number: step.number,
      completed?: step.changeset.valid?,
      current?: current_step == step.number
    }
  end
end
