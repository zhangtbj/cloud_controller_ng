Dir[File.expand_path('../../app/models/**/*.rb', __FILE__)].each do |file|
  require file
end
