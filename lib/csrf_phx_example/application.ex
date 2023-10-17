defmodule CsrfPhxExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CsrfPhxExampleWeb.Telemetry,
      # Start the Ecto repository
      CsrfPhxExample.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: CsrfPhxExample.PubSub},
      # Start Finch
      {Finch, name: CsrfPhxExample.Finch},
      # Start the Endpoint (http/https)
      CsrfPhxExampleWeb.Endpoint,
      {CsrfPlus.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CsrfPhxExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CsrfPhxExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
