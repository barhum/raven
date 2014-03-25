class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/raven_config.yml" do 
      "user: ernest
       secret: all good men die young"
    end  
  end
end


