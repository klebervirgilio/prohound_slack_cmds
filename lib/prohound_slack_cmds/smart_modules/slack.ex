defmodule ProhoundSlackCmds.SmartModule.Slack do
  alias ProhoundSlackCmds.SmartModule.Model
  alias ProhoundSlackCmds.HTTP

  def view do
    models = Model.all()
    offline = Enum.filter(models, &offline?/1)
    online = Enum.filter(models, &online?/1)

    online_percent = Enum.count(online) / Enum.count(models) * 100
    offline_percent = 100.0 - online_percent

    %{
      response_type: "in_channel",
      attachments: [
        %{
          title: "SmartModule Online (#{online_percent}%)",
          text: online |> attachment_text(),
          color: "good"
        },
        %{
          title: "SmartModule Offline (#{offline_percent}%)",
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
    |> Enum.map(&to_s/1)
    |> Enum.join("\n")
  end

  def to_s(model) do
    ~s"""
    (#{model.id}) *#{model.peer}* - #{format_date(model.latest_sync)}
    #{model.group} > #{model.branch} > #{model.account}

    Sensor: #{model.sensor_title}
    Localização: #{model.sensor_location}
    Tipo: #{model.sensor_type}
    """
  end

  def format_date(datetime) when is_nil(datetime), do: "Nunca"

  def format_date(datetime) do
    Timex.format!(brazilian_time_zone(datetime), "%y-%m-%d %H:%M:%S", :strftime)
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
