defmodule Jira.API do
  use HTTPoison.Base

  ### HTTPoison.Base callbacks
  def process_url(url) do
    System.get_env("JIRA_HOST") <> url
  end

  def process_response_body(body) do
    body
    |> decode_body
  end

  defp decode_body(""), do: ""
  defp decode_body(body), do: body |> Poison.decode!

  ### Internal Helpers
  def authorization_header do
    credentials = encoded_credentials(System.get_env("JIRA_USERNAME"), System.get_env("JIRA_PASSWORD"))
    "Basic #{credentials}"
  end

  defp encoded_credentials(username, password) do
    "#{username}:#{password}"
    |> Base.encode64
  end

  ### API
  def boards do
    get!("/rest/greenhopper/1.0/rapidview", [authorization: authorization_header]).body
  end

  def sprints(board_id) when is_integer(board_id) do
    get!("/rest/greenhopper/1.0/sprintquery/#{board_id}", [authorization: authorization_header]).body
  end
  def sprints(%{"id"=>board_id}), do: sprints(board_id)

  def sprint_report(board_id, sprint_id) do
    get!("/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=#{board_id}&sprintId=#{sprint_id}", [authorization: authorization_header]).body
  end

  def ticket_details(key) do
    get!("/rest/api/2/issue/#{key}", [authorization: authorization_header]).body
  end

  def add_ticket_link(key, title, link) do
    body = %{"object" => %{"url" => link, "title" => title}} |> Poison.encode!
    post!("/rest/api/2/issue/#{key}/remotelink", body, [{"authorization", authorization_header}, {"Content-type", "application/json"}])
  end

  def add_ticket_watcher(key, username) do
    body = username |> Poison.encode!
    post!("/rest/api/2/issue/#{key}/watchers", body, [{"authorization", authorization_header}, {"Content-type", "application/json"}])
  end

  def search(query) do
    body = query |> Poison.encode!
    post!("/rest/api/2/search", body, [{"authorization", authorization_header}, {"Content-type", "application/json"}])
  end

end
