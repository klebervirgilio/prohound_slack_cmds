defmodule ProhoundSlackCmds.SmartCentre.ES do
  require HTTPoison
  require Poison

  @es_query ~S"""
  {
    "query": {
      "bool": {
        "must": [
          {
            "match": {
              "event_type": "Measurements::GatewayLastSyncronized"
            }
          },
          {
            "match": {
              "stream": "Gateway$<%= gateway_id %>"
            }
          }
        ]
      }
    },
    "_source": ["gateway_id", "timestamp"],
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

  def latest_sync(gateway_id) do
    case HTTPoison.request(:get, es_url(), body(gateway_id), headers()) do
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
      hits |> hd |> Map.get("_source") |> Map.get("timestamp")
    else
      nil
    end
  end

  def body(gateway_id) do
    EEx.eval_string(@es_query, gateway_id: gateway_id)
  end

  def headers do
    ["Content-Type": "application/json"]
  end

  def es_url do
    Application.get_env(:prohound_slack_cmds, :es) |> Map.get(:url)
  end
end
