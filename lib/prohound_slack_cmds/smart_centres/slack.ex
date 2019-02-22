defmodule ProhoundSlackCmds.SmartCentre.Slack do
  alias ProhoundSlackCmds.SmartCentre.Model
  require IEx

  def view do
    models = Model.all()
    offline = Enum.filter(models, &offline?/1)
    online = Enum.filter(models, &online?/1)

    online_percent = Enum.count(online) / Enum.count(models) * 100
    offline_percent = 100.0 - online_percent

    %{
      attachments: [
        %{
          title: "SmartCentre Online (#{online_percent}%)",
          text: online |> attachment_text(),
          color: "good"
        },
        %{
          title: "SmartCentre Offline (#{offline_percent}%)",
          text: offline |> attachment_text(),
          color: "danger"
        }
      ]
    }
  end

  def post(url) do
    json = to_json()
    IO.puts(json)

    case HTTPoison.post(url, json, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.puts("OOOOOKKKKK")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
    end
  end

  def to_json do
    {:ok, json} = Poison.encode(view())
    json
  end

  def attachment_text(models) do
    models
    |> Enum.map(&to_s/1)
    |> Enum.join("\n")
  end

  def to_s(model) do
    "*#{model.registration_code}* - #{model.group} > #{model.branch} > #{model.account_name}"
  end

  def online?(model) do
    model
    |> offline?()
    |> Kernel.not()
  end

  def offline?(model) do
    if model.latest_sync do
      Timex.before?(model.latest_sync, Timex.shift(Timex.now(), minutes: -31))
    else
      true
    end
  end

  def brazilian_time_zone(model) do
    if model.latest_sync do
      Timex.Timezone.convert(model.latest_sync, Timex.Timezone.get("America/Sao_Paulo"))
    else
      nil
    end
  end
end
