defmodule ProhoundSlackCmds.SmartModule.Slack do
  alias ProhoundSlackCmds.SmartModule.Model
  alias ProhoundSlackCmds.HTTP

  require IEx

  def view do
    models = Model.all()

    offline = Enum.filter(models, &offline?/1)
    online = Enum.filter(models, &online?/1)

    %{
      response_type: "in_channel",
      attachments: [
        %{
          title: "SmartModule Online",
          text: online |> attachment_text(),
          color: "good"
        },
        %{
          title: "SmartModule Offline",
          text: offline |> attachment_text(),
          color: "danger"
        }
      ]
    }
  end

  def post(url) do
    HTTP.post(url, to_json())
  end

  def to_json do
    {:ok, json} = Poison.encode(view())
    json
  end

  def attachment_text(models) do
    models
    |> Enum.group_by(fn model -> model.id end)
    |> Enum.map(&to_s/1)
    |> Enum.join("\n")
  end

  def to_s(model) do
    {_, peers} = model
    peer = peers |> hd

    sensors =
      peers
      |> Enum.map(fn p ->
        "#{p.sensor_title} | #{p.sensor_location} | #{p.sensor_type}"
      end)
      |> Enum.join("\n")

    ~s"""
    *#{peer.peer}* - #{format_date(peer.latest_sync)} #{peer.group} > #{peer.branch} > #{
      peer.account
    }

    Sensores:
    #{sensors}
    """
  end

  def format_date(datetime) when is_nil(datetime), do: "Nunca"

  def format_date(datetime) do
    Timex.format!(brazilian_time_zone(datetime), "%Y-%m-%d %H:%M:%S", :strftime)
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

  def brazilian_time_zone(datetime) do
    Timex.Timezone.convert(datetime, Timex.Timezone.get("America/Sao_Paulo"))
  end
end
