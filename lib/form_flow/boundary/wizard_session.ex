defmodule FormFlow.Boundary.WizardSession do
  use GenServer

  alias FormFlow.{
    Core.Wizard
  }

  # Public Api

  def new(wizard_params) do
    DynamicSupervisor.start_child(
      FormFlow.Supervisor.WizardSession,
      {__MODULE__, wizard_params}
    )
  end

  def next_step(session, params) do
    GenServer.call(via(session), {:next_step, params})
  end

  def get_state(session) do
    GenServer.call(via(session), :get_state)
  end

  # Callbacks

  def child_spec(wizard_params) do
    %{
      id: {__MODULE__, {wizard_params.name, wizard_params.session_id}},
      start: {__MODULE__, :start_link, [wizard_params]},
      restart: :temporary
    }
  end

  def start_link(wizard_params) do
    GenServer.start_link(__MODULE__, wizard_params,
      name: via({wizard_params.name, wizard_params.session_id})
    )
  end

  @impl true
  def init(wizard_params) do
    {:ok, Wizard.new(wizard_params)}
  end

  @impl true
  def handle_call(:get_state, _from, wizard) do
    {:reply, Wizard.state(wizard), wizard}
  end

  @impl true
  def handle_call({:next_step, params}, _from, wizard) do
    wizard = Wizard.next(wizard, params)
    {:reply, Wizard.state(wizard), wizard}
  end

  defp via(name) do
    {
      :via,
      Registry,
      {FormFlow.Registry.WizardSession, name}
    }
  end
end
