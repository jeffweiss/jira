defmodule Jira.API do
  use HTTPoison.Base

  defp config_or_env(key, env_var) do
    Application.get_env(:jira, key, System.get_env(env_var))
  end

  defp host do
    config_or_env(:host, "JIRA_HOST")
  end

  defp username do
    config_or_env(:username, "JIRA_USERNAME")
  end

  defp password do
    config_or_env(:password, "JIRA_PASSWORD")
  end

  ### HTTPoison.Base callbacks
  def process_url(url) do
    host <> url
  end

  def process_response_body(body) do
    body
    |> decode_body
  end

  def process_request_headers(headers) do
    [{"authorization", authorization_header}|headers]
  end

  defp decode_body(""), do: ""
  defp decode_body(body), do: body |> Poison.decode!

  ### Internal Helpers
  def authorization_header do
    credentials = encoded_credentials(username, password)
    "Basic #{credentials}"
  end

  defp encoded_credentials(user, pass) do
    "#{user}:#{pass}"
    |> Base.encode64
  end

  ### API
  def boards do
    get!("/rest/greenhopper/1.0/rapidview").body
  end

  def sprints(board_id) when is_integer(board_id) do
    get!("/rest/greenhopper/1.0/sprintquery/#{board_id}").body
  end
  def sprints(%{"id"=>board_id}), do: sprints(board_id)

  def sprint_report(board_id, sprint_id) do
    get!("/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=#{board_id}&sprintId=#{sprint_id}").body
  end

  def ticket_details(key) do
    get!("/rest/api/2/issue/#{key}").body
  end

  def add_ticket_link(key, title, link) do
    body = %{"object" => %{"url" => link, "title" => title}} |> Poison.encode!
    post!("/rest/api/2/issue/#{key}/remotelink", body, [{"Content-type", "application/json"}])
  end

  def add_ticket_watcher(key, username) do
    body = username |> Poison.encode!
    post!("/rest/api/2/issue/#{key}/watchers", body, [{"Content-type", "application/json"}])
  end

  def search(query) do
    body = query |> Poison.encode!
    post!("/rest/api/2/search", body, [{"Content-type", "application/json"}])
  end

end
