defmodule ProhoundSlackCmds.Event.ES do
  require HTTPoison
  require Poison

  @es_query ~S"""
  {
    "query": {
      "bool": {
        "must": [
          {
            "match": {
              "event_type": "<%= event_type %>"
            }
          },
          {
            "match": {
              "stream": "<%= stream %>"
            }
          }
        ]
      }
    },
    "_source": ["raw"],
    "sort": [
      {
        "timestamp": {
          "order": "desc"
        }
      }
    ],
    "size": 1
  }'
  """

  def latest(stream, event_type) do
    case HTTPoison.request(:get, es_url(), body(stream, event_type), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: b}} ->
        b |> Poison.decode!() |> process_body()

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
        nil
    end
  end

  def process_body(b) do
    hits = b |> Map.get("hits", %{}) |> Map.get("hits", [])

    if length(hits) == 1 do
      hits |> hd |> Map.get("_source") |> Map.get("raw")
    else
      nil
    end
  end

  def body(stream, event_type) do
    EEx.eval_string(@es_query, stream: stream, event_type: event_type)
  end

  def headers do
    ["Content-Type": "application/json"]
  end

  def es_url do
    Application.get_env(:prohound_slack_cmds, :es) |> Map.get(:url)
  end
end
