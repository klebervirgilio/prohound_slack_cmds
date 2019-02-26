defmodule ProhoundSlackCmds.ES do
  def do_request(body) when is_binary(body) do
    IO.puts(body)

    case HTTPoison.request(:get, es_url(), body, headers()) do
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

  def headers do
    ["Content-Type": "application/json"]
  end

  def es_url do
    Application.get_env(:prohound_slack_cmds, :es) |> Map.get(:url)
  end
end
