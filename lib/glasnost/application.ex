defmodule Glasnost.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Glasnost.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Glasnost.Web.Endpoint, []),
      supervisor(ConCache, [[ ttl_check: :timer.minutes(1), ttl: :timer.minutes(30) ], [name: :config_cache]]),
      worker(Glasnost.RuntimeConfig, [%{},[name: :runtime_config]]),
      supervisor(Glasnost.SimpleAuthenticator, []),
      supervisor(Glasnost.Orchestrator.AuthorSyncSup, []),
      worker(Exos.Proc, [{"node port.js",0,cd: "./lib/ports/js"}] )
      # Start your own worker by calling: Glasnost.Worker.start_link(arg1, arg2, arg3)
      # worker(Glasnost.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Glasnost.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
