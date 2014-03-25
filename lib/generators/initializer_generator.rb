class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    out_file = File.new("config/initializers/config.rb", "w+")
    out_file.puts(
     "def user
        @user = 'ernest'
      end

      def secret  
        @secret = 'all good men die young'
      end
      
      def gateway  
        @gateway =  'https://demo.pacnetservices.com/realtime'
      end

      def prefix
        @prefix = 'TEST'
      end

      def raven_debug
        @raven_debug = 'off'
      end
      
      def rapi_version   
        @rapi_version =  2
      end
      
      def rapi_interface
        @rapi_interface = 'rails0.1'
      end")
    out_file.close
  end
end


