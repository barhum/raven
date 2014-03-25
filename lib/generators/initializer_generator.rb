class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/raven_init.yml", "# Add initialization content here"
  end
end


