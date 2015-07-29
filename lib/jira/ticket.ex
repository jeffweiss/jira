defmodule Jira.Ticket do
  def get(key) do
    ConCache.get_or_store(:jira_cache, key, fn() -> Jira.API.ticket_details(key) end)
  end

  # This custom field is unique to my particular site. I'll add in an abstraction in a later release.
  def scope_change_category(%{"fields" => %{"customfield_11802" => %{"value" => category}}}) when category != nil, do: category
  def scope_change_category(_), do: nil

  # If you use Greenhopper/Jira Agile, this *should* consistently be the field for estimates
  def estimate(%{"fields" => %{"customfield_10002" => estimate}}) when is_number(estimate), do: estimate
  def estimate(_), do: 0
end
