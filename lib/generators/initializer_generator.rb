class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/raven_config.rb" do 
      @user = 'ernest'
      @secret = 'all good men die young'
      @gateway =  'https://demo.pacnetservices.com/realtime'
      @prefix = 'TEST'
      @raven_debug = 'off' 
      @rapi_version =  2 
      @rapi_interface = "rails0.1"
    end  
  end
end


