Sequel.migration do
  change do
    alter_table :apps do
      add_column :next_droplet_guid, String, null: true
    end
  end
end
