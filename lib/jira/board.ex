defmodule Jira.Board do
  def all do
    Jira.API.boards()
    |> Map.get("views")
  end

  def all(like: regex) do
    all
    |> filter_for_name(regex)
  end

  def all(sprints: val) do
    all
    |> filter_for_sprints_enabled(val)
  end

  def all(like: regex, sprints: val) do
    all
    |> filter_for_name(regex)
    |> filter_for_sprints_enabled(val)
  end

  defp filter_for_name(list, regex) do
    list
    |> Enum.filter(fn %{"name" => name} -> Regex.match?(regex, name) end)
  end

  defp filter_for_sprints_enabled(list, val) do
    list
    |> Enum.filter(fn %{"sprintSupportEnabled" => sprints} -> sprints == val end)
  end
end
