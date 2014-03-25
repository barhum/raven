class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb" do 
      att_reader :ravenUser

      def ravenUser
        @ravenUser = 'ernest'
      end  
    end  
  end
end


