defmodule Jira do
  use HTTPoison.Base

  def process_url(url) do
    "https://tickets.puppetlabs.com" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end

  def boards_with_sprints do
    get!("/rest/greenhopper/1.0/rapidview", [authorization: authorization_header]).body["views"]
    |> Enum.filter(fn (m) -> m["sprintSupportEnabled"] end)
  end

  def boards_with_sprints(regex) do
    boards_with_sprints
    |> Enum.filter(fn (%{"name" => name}) -> Regex.match?(regex, name) end)
  end

  def encoded_credentials(username, password) do
    "#{username}:#{password}"
    |> Base.encode64
  end

  def authorization_header do
    credentials = encoded_credentials(System.get_env("JIRA_USERNAME"), System.get_env("JIRA_PASSWORD"))
    "Basic #{credentials}"
  end

  def sprints(id) when is_integer(id) do
    get!("/rest/greenhopper/1.0/sprintquery/#{id}", [authorization: authorization_header]).body["sprints"]
  end
  def sprints(%{"id"=>id}), do: sprints(id)

  def sprint_report(board_id, sprint_id) do
    get!("/rest/greenhopper/1.0/rapid/chards/sprint_report?rapidViewId=#{board_id}&sprintId=#{sprint_id}", [authorization: authorization_header]).body
  end

  def ticket_details(key) do
    get!("/rest/api/2/issue/#{key}", [authorization: authorization_header]).body
  end

  def current_sprint(id) do
    sprints(id)
    |> filter_sprints_for_state("ACTIVE")
  end

  def closed_sprints(id) do
    sprints(id)
    |> filter_sprints_for_state("CLOSED")
  end

  defp filter_sprints_for_state(sprints, desired_state) do
    sprints
    |> Enum.filter(fn(%{"state"=>state}) -> state == desired_state end)
  end

  def scope_change_query(board_id, [current: current]) do
    sprints(board_id)
    |> find_comparable_sprints(current)
    |> jql_query
  end
  defp find_comparable_sprints(sprints, true) do
    active = sprints |> filter_sprints_for_state("ACTIVE") |> Enum.reverse
    complete = sprints |> filter_sprints_for_state("CLOSED") |> Enum.reverse
    {List.first(active), List.first(complete)}
  end
  defp find_comparable_sprints(sprints, false) do
    complete = sprints |> filter_sprints_for_state("CLOSED") |> Enum.reverse
    [first, second] = complete |> Enum.take(2)
    {first, second}
  end

  defp jql_query({nil, _}) do
    ""
  end
  defp jql_query({%{"id"=>current_sprint_id}, nil}) do
    "sprint = #{current_sprint_id} AND \"Scope Change Category\" is not EMPTY"
  end
  defp jql_query({%{"id"=>current_sprint_id}, %{"id"=>previous_sprint_id}}) do
    "sprint = #{current_sprint_id} AND sprint != #{previous_sprint_id} AND \"Scope Change Category\" is not EMPTY"
  end

end
