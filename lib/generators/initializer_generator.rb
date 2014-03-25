class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    out_file = File.new("config/initializers/raven_config.rb", "w")
    out_file.puts do 
     "@user = 'ernest'
      @secret = 'all good men die young'
      @gateway =  'https://demo.pacnetservices.com/realtime'
      @prefix = 'TEST'
      @raven_debug = 'off' 
      @rapi_version =  2 
      @rapi_interface = 'rails0.1'"
    end  
    out_file.close
  end
end


