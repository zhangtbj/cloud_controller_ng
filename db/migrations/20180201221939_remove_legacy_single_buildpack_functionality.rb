Sequel.migration do
  change do
    drop_column :buildpack_lifecycle_data, :admin_buildpack_name
    drop_column :buildpack_lifecycle_data, :encrypted_buildpack_url
    drop_column :buildpack_lifecycle_data, :encrypted_buildpack_url_salt
  end
end
