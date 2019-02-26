defmodule ProhoundSlackCmds.SmartModule.ES do
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
              "event_type": "Measurements::PeerLastSyncronized"
            }
          },
          {
            "match": {
              "stream": "Peer$<%= peer_id %>"
            }
          }
        ]
      }
    },
    "_source": ["peer_id", "timestamp"],
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

  def latest_sync(peer_id) do
    peer_id |> body() |> do_request
  end

  def body(peer_id) do
    EEx.eval_string(@es_query, peer_id: peer_id)
  end
end
