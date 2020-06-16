defmodule FormFlow.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: FormFlow.Registry.WizardSession},
      {DynamicSupervisor, name: FormFlow.Supervisor.WizardSession, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: FormFlow.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
