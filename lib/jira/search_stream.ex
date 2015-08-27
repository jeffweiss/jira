defmodule Jira.SearchStream do
  def new(jql) do
    Stream.resource(
      fn -> fetch_query(jql) end,
      &process_query/1,
      fn _ -> end
    )
  end

  defp fetch_query(jql) when is_binary(jql), do: fetch_query(%{"jql" => jql})
  defp fetch_query(query = %{"jql" => jql}) when is_map(query) do
    response = Jira.API.search(query)
    page_size = response.body["maxResults"]
    current_start_at = response.body["startAt"]
    next_start_at = page_size + current_start_at
    total = response.body["total"]
    issues = response.body["issues"]
    next_query = if next_start_at >= total, do: nil, else: %{"jql" => jql, "maxResults" => page_size, "startAt" => next_start_at}

    {issues, next_query}
  end

  defp process_query({[], nil}) do
    {:halt, nil}
  end
  defp process_query({[], next_query}) do
    next_query
    |> fetch_query
    |> process_query
  end
  defp process_query({items, next_query}) do
    {items, {[], next_query}}
  end
end
