defmodule Jira.SprintReport do

  def get(board_id, sprint_id) do
    Jira.API.sprint_report(board_id, sprint_id)
  end

  def name(%{"sprint" => %{"name" => name}}) when name != nil, do: name
  def name(_), do: "UNKNOWN"


  def statistics(sprint_report) do
    statistics(sprint_report, scope_change_detail(sprint_report))
  end

  def statistics(sprint_report, scope_change_details) do
    points_committed = committed_points(sprint_report)
    points_completed = completed_points(sprint_report)
    aggregate_scope_change = scope_change_details
      |> Enum.group_by(fn {_, _, x} -> x end)
      |> Enum.map(fn {category, list} -> {category |> category_to_atom, list |> Enum.map(fn {_, x, _} -> x end) |> Enum.sum} end)

    [aggregate_scope_change, committed: points_committed, completed: points_completed, scope_change: scope_change_query(sprint_report)]
    |> List.flatten
    |> Enum.into(%{:name => name(sprint_report), :uncategorized_tickets => net_added_scope_ticket_keys(sprint_report)})
  end

  defp category_to_atom(nil), do: :nil
  defp category_to_atom(category), do: category |> String.downcase |> String.to_atom

  def completed_points(%{"contents" => %{"completedIssuesEstimateSum" => %{"value" => value}}}) when is_number(value), do: value
  def completed_points(_), do: 0

  def committed_points(%{"contents" => %{"issueKeysAddedDuringSprint" => scope_change_list, "puntedIssues" => removed_issues_list, "incompletedIssues" => incomplete_issues_list, "completedIssues" => completed_issues_list}}) do
    scope_add_keys = Map.keys(scope_change_list)
    [removed_issues_list, incomplete_issues_list, completed_issues_list]
    |> Enum.map(fn(x) -> estimate_sum(x, scope_add_keys, :exclude_scope_changes) end)
    |> Enum.sum
  end
  def committed_points(_), do: 0

  def added_scope_points(%{"contents" => %{"issueKeysAddedDuringSprint" => scope_change_list, "incompletedIssues" => incomplete_issues_list, "completedIssues" => completed_issues_list}}) do
    scope_add_keys = Map.keys(scope_change_list)
    [incomplete_issues_list, completed_issues_list]
    |> Enum.map(fn(x) -> estimate_sum(x, scope_add_keys, :only_scope_changes) end)
    |> Enum.sum
  end
  def added_scope_points(_), do: 0

  def added_scope_ticket_keys(%{"contents" => %{"issueKeysAddedDuringSprint" => scope_change_list}}) do
      scope_change_list
      |> Map.keys
  end

  def removed_scope_ticket_keys(%{"contents" => %{"puntedIssues" => removed_issues_list}}) do
    removed_issues_list
    |> Enum.map(fn(%{"key" => key}) -> key end)
  end

  def net_added_scope_ticket_keys(sprint_report) do
    added_scope_ticket_keys(sprint_report) -- removed_scope_ticket_keys(sprint_report)
  end

  def ticket_detail_by_key(%{"contents" => %{"puntedIssues" => removed_issues_list, "incompletedIssues" => incomplete_issues_list, "completedIssues" => completed_issues_list}}, ticket_key) do
    [removed_issues_list, completed_issues_list, incomplete_issues_list]
    |> List.flatten
    |> Enum.filter(fn(%{"key" => key}) -> key == ticket_key end)
    |> List.first
  end
  def ticket_detail_by_key(_), do: nil

  def scope_change_query(sprint_report) do
    "key in (#{net_added_scope_ticket_keys(sprint_report) |> Enum.join (", ")})"
  end

  def scope_change_detail(sprint_report) do
    sprint_report
    |> net_added_scope_ticket_keys
    |> Enum.map(fn(key) -> {key, ticket_detail_by_key(sprint_report, key) |> estimate_statistic_from_sprint_report_ticket_info, Jira.Ticket.get(key) |> Jira.Ticket.scope_change_category } end)
  end

  defp estimate_sum(list, scope_change_keys, filter_key) do
    list
    |> filter_ticket_list(scope_change_keys, filter_key)
    |> Enum.map(&estimate_statistic_from_sprint_report_ticket_info/1)
    |> Enum.sum
  end

  defp filter_ticket_list(list, scope_change_keys, :only_scope_changes) do
    Enum.filter(list, fn(%{"key" => key}) -> Enum.member?(scope_change_keys, key) end)
  end
  defp filter_ticket_list(list, scope_change_keys, :exclude_scope_changes) do
    Enum.reject(list, fn(%{"key" => key}) -> Enum.member?(scope_change_keys, key) end)
  end
  defp filter_ticket_list(list, _, _), do: list


  defp estimate_statistic_from_sprint_report_ticket_info(%{"estimateStatistic" => %{"statFieldValue" => %{"value" => value}}}) when is_number(value), do: value
  defp estimate_statistic_from_sprint_report_ticket_info(_), do: 0

end

