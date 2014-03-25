class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/raven_config.yml" do 
      @ravenUser = 'ernest' 
    end  
  end
end


