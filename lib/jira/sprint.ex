defmodule Jira.Sprint do
  def all(board_id) do
    Jira.API.sprint(board_id)
    |> Map.get("sprints")
  end
end
