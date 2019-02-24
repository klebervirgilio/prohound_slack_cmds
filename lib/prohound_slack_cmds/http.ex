defmodule ProhoundSlackCmds.HTTP do
  def post(url, payload) do
    IO.puts(payload)

    case HTTPoison.post(url, payload, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.puts("OOOOOKKKKK")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
    end
  end
end
