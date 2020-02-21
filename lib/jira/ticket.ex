defmodule Jira.Ticket do
  def get(key) do
    Jira.API.ticket_details(key)
  end

  # If you use Greenhopper/Jira Agile, this *should* consistently be the field for estimates
  def estimate(%{"fields" => %{"customfield_10002" => estimate}}) when is_number(estimate),
    do: estimate

  def estimate(_), do: 0

  def add_link(key, title, link) do
    Jira.API.add_ticket_link(key, title, link)
  end

  def add_watcher(key, username) do
    Jira.API.add_ticket_watcher(key, username)
  end
end
