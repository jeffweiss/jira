defmodule SprintReports do
  def create_sprint_queries(last_n_sprints \\ 2) do
  end

  def found_work_metrics(board_id, sprint_id) do
    report = get_sprint_report(board_id, sprint_id)

    found_work = get_scope_changes(report)
    |> classify

    compile_report(report, found_work)
  end

  def get_scope_changes(sprint_report) do
    sprint_report["contents"]["issueKeysAddedDuringSprint"]
    |> Map.keys
  end


  def classify(list_of_ticket_keys) do
    list_of_ticket_keys
#    |> Enum.map()
  end

  def ticket_detail(key) do
    Jira.ticket_details(key)
  end

  def get_sprint_report(board_id, sprint_id) do
    Jira.sprint_report(board_id, sprint_id)
  end

  def compile_report(report, found_work) do

  end

  def statistics(sprint_report) do
  end

  def completed(%{"contents" => %{"completedIssuesEstimateSum" => %{"value" => value}}}) when is_number(value), do: value
  def completed(_), do: 0

  def committed(%{"contents" => %{"issueKeysAddedDuringSprint" => scope_change_list, "puntedIssues" => removed_issues_list, "incompletedIssues" => incomplete_issues_list, "completedIssues" => completed_issues_list}}) do
    scope_add_keys = Map.keys(scope_change_list)
    [removed_issues_list, incomplete_issues_list, completed_issues_list]
    |> Enum.map(fn(x) -> estimate_sum(x, scope_add_keys, :exclude_scope_changes) end)
    |> Enum.sum
  end
  def committed(_), do: 0

  def scope_change_add(%{"contents" => %{"issueKeysAddedDuringSprint" => scope_change_list, "puntedIssues" => removed_issues_list, "incompletedIssues" => incomplete_issues_list, "completedIssues" => completed_issues_list}}) do
    scope_add_keys = Map.keys(scope_change_list)
    [incomplete_issues_list, completed_issues_list]
    |> Enum.map(fn(x) -> estimate_sum(x, scope_add_keys, :only_scope_changes) end)
    |> Enum.sum
  end
  def scope_change_add(_), do: 0

  def estimate_sum(list, scope_change_keys, filter_key) do
    list
    |> filter_ticket_list(scope_change_keys, filter_key)
    |> Enum.map(&estimate_statistic_from_sprint_report_ticket_info/1)
    |> Enum.sum
  end

  def filter_ticket_list(list, scope_change_keys, :only_scope_changes) do
    Enum.filter(list, fn(%{"key" => key}) -> Enum.member?(scope_change_keys, key) end)
  end
  def filter_ticket_list(list, scope_change_keys, :exclude_scope_changes) do
    Enum.reject(list, fn(%{"key" => key}) -> Enum.member?(scope_change_keys, key) end)
  end
  def filter_ticket_list(list, _, _), do: list


  def estimate_statistic_from_sprint_report_ticket_info(%{"estimateStatistic" => %{"statFieldValue" => %{"value" => value}}}) when is_number(value), do: value
  def estimate_statistic_from_sprint_report_ticket_info(_), do: 0

end

