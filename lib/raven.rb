require 'config'
require 'debugger'

module Raven
  class RavenException < Exception
    "A problem has occurred with some aspect of Raven processing."
    #
    # Raven is not properly configured, probably due to a missing configuration 
    # file or absent mandatory configuration parameter (see 
    # http://docs.deepcovelabs.com/raven/api-guide/).
    #  
  end
  
  class RavenConfigurationException < RavenException
    " Raven is not properly configured, probably due to a missing
    configuration file or absent mandatory configuration parameter 
    (see http://docs.deepcovelabs.com/raven/api-guide/)."

    #
    # A requested Raven operation is not defined in the targeted version of
    # the API (as specified by the request parameter "RAPIVersion").
    # (see http://docs.deepcovelabs.com/raven/api-guide/).
    #
  end

  class RavenNoSuchOperationException < RavenException
        " A requested Raven operation is not defined in the targeted version 
    of the API, as specified by the request parameter #{'insert rapiversion here'} (see
    http://docs.deepcovelabs.com/raven/api-guide/)."

    # This exception will be thrown if no response was received from the Raven
    # system. This may be due to network issues or if there was a server 500 
    # errror.
    # 
    # If this exception is thrown you should make a response request with the 
    # RequestID used (see http://docs.deepcovelabs.com/raven/api-guide/).
    #
  end

  class RavenNoResponseException < RavenException
    " This exception will be thrown if no response was received from the
    Raven system. This may be due to network issues or if there was a 
    server 500 errror. If this exception is thrown you should make a
    response request with the RequestID used (see
    http://docs.deepcovelabs.com/raven/api-guide/)."

    # A Raven operation or response was not properly authenticated.
  end

  class RavenAuthenticationException < RavenException
    " A Raven operation or response was not properly authenticated."

    # Abstract class to handle common functionality between RavenRequest and 
    # RavenResponse.     
  end  

  class Raven
    attr_reader :values, :operation

    def initialize(operation)
      @values = {}
      if !self.ravenOperations.include?(operation.to_s)
        raise RavenNoSuchOperationException("#{operation} is an unsupported operation.")
      end
      @operation = operation         
    end

    def ravenOperations
      @ravenOperations = ['submit','closefile','response','void','hello','payments','events','status']
    end

    def get(*args)
      args.each do |arg|
        if (@values[arg] != nil)
          return @values[arg]
        end  
      end   
    end

    def printValues
      print @values.values 
    end  
  end

  class RavenRequest < Raven
    def set(key, value)
      @values[key] = value.to_s
    end
  end 
end 


