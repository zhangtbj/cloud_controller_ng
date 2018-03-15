Sequel.migration do
  change do
    alter_table :processes do
      add_column :revision, Integer, null: true, default: 1
    end
  end
end
