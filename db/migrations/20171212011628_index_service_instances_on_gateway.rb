Sequel.migration do
  change do
    alter_table :service_instances do
      add_index :is_gateway_service, name: :gateway_service_index
    end
  end
end
