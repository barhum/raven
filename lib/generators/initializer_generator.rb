class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/raven_config.yml" do 
      "user: ernest \n
       secret: all good men die young \n
       gateway: https://demo.pacnetservices.com/realtime \n
       prefix: TEST \n
       raven_debug: off \n
       rapi_version: 2 \n
       rapi_interface: rails0.1"
    end  
  end
end


