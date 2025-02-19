defmodule ProhoundSlackCmds.SmartCentre.ES do
  require HTTPoison
  require Poison

  import ProhoundSlackCmds.ES

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
    gateway_id |> body() |> do_request
  end

  def body(gateway_id) do
    EEx.eval_string(@es_query, gateway_id: gateway_id)
  end
end
