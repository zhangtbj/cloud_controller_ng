Sequel.migration do
  change do
    alter_table :route_mappings do
      drop_constraint(:route_mappings_app_guid_route_guid_process_type_app_port_key)
      # future: add uniqueness constraint including revision
    end
  end
end
