Sequel.migration do
  change do
    alter_table :route_mappings do
      add_column :revision, Integer, null: true
    end
  end
end
