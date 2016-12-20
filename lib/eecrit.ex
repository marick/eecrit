defmodule Eecrit do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repositories
      supervisor(Eecrit.Repo, []),
      supervisor(Eecrit.OldRepo, []),
      # Start the endpoint when the application starts
      supervisor(Eecrit.Endpoint, []),
      # Start your own worker by calling: Eecrit.Worker.start_link(arg1, arg2, arg3)
      # worker(Eecrit.Worker, [arg1, arg2, arg3]),
      worker(Eecrit.Animals, [Eecrit.Animals])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eecrit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Eecrit.Endpoint.config_change(changed, removed)
    :ok
  end
end
