defmodule Jira.Ticket do
  def get(key) do
    Jira.API.ticket_details(key)
  end

  def custom_field(%{"fields" => fields}, custom_field) do
    case Map.has_key?(fields, custom_field) do
      true -> Map.get(fields, custom_field)
      false -> :invalid_field
    end
  end

  # If you use Greenhopper/Jira Agile, this *should* consistently be the field for estimates
  def estimate(%{"fields" => %{"customfield_10002" => estimate}}) when is_number(estimate),
    do: estimate

  def estimate(_), do: 0

  def set_custom_field(key, custom_field, value) do
    Jira.API.set_custom_field(key, custom_field, value)
  end

  def set_estimate(key, estimate) do
    Jira.API.set_ticket_estimate(key, estimate)
  end

  def add_link(key, title, link) do
    Jira.API.add_ticket_link(key, title, link)
  end

  def add_watcher(key, username) do
    Jira.API.add_ticket_watcher(key, username)
  end
end
