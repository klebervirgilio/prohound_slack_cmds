defmodule ProhoundSlackCmds.SmartModule.Repo do
  import ProhoundSlackCmds.Repo

  @base_query ~S"""
  select
    accounts.name as account,
    machines.title as machine,
    group_categories.name as branch,
    groups.title as group,
    peers.id as id,
    peers.registration_code as peer,
    sensors.title as sensor_title,
    sensors.registration_code as sensor_registration_code,
    sensors.id as sensor_id,
    sensors.location as sensor_location,
    sensors.type as sensor_type,
    sensors.type_category as sensor_type_category
  from peers
  inner join accounts on accounts.id = peers.account_id
  inner join machines on machines.id = peers.machine_id
  inner join groups on groups.id = machines.group_id
  inner join group_categories on group_categories.id = groups.group_category_id
  inner join sensors on sensors.sensorable_type = 'Peer' and sensors.sensorable_id = peers.id and sensors.enabled = 't';
  """

  def find_all do
    case exec_query(@base_query) do
      {:ok, result} ->
        result
        |> zip_columns_and_rows()

      {:error, message} ->
        IO.puts(message)
        -1
    end
  end
end
