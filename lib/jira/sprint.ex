defmodule Jira.Sprint do
  def all(board_id) do
    Jira.API.sprints(board_id)
    |> Map.get("sprints")
  end
end
