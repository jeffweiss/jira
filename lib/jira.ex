defmodule Jira do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ConCache, [
        [
          ttl_check: :timer.seconds(30),
          ttl: :timer.minutes(5)
        ],
        [name: :jira_cache]
      ])
    ]

    opts = [strategy: :one_for_one, name: Jira.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
