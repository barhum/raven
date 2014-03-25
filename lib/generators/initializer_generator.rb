class InitializerGenerator < Rails::Generators::Base
  RavenConfig.setUser('ernest')
  RavenConfig.setSecret('all good men die young')
  RavenConfig.setGateway("https://demo.pacnetservices.com/realtime")
  RavenConfig.setPrefix("TEST")
  RavenConfig.setDebug('off')
end


