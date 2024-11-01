defmodule Beast.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Beast.Repo,
      # Start the Telemetry supervisor
      BeastWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Beast.PubSub},
      # Start the Endpoint (http/https)
      BeastWeb.Endpoint,
      # Start a worker by calling: Beast.Worker.start_link(arg)
      # {Beast.Worker, arg}
      {Beast.TickerAgent, []},
      {Beast.Polygon, ["Beast numbers are Great"]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Beast.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeastWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
