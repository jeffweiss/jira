defmodule Jira.Ticket do
  def get(key) do
    Jira.API.ticket_details(key)
  end

  def scope_change_category(%{"fields" => %{"customfield_11802" => %{"value" => category}}}) when category != nil, do: category
  def scope_change_category(_), do: nil

  def estimate(%{"fields" => %{"customfield_10002" => estimate}}) when is_number(estimate), do: estimate
  def estimate(_), do: 0
end
