require 'config.rb'
require 'debugger'
require 'digest/hmac'
require 'uri'

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
    attr_reader :ravenRequestString

    def initialize(operation)
      super
      @ravenRequestString = nil
      self.set('username', Config.RAVEN_USERNAME)
      self.set('RAPIVersion', Config.RAPI_VERSION)
      self.set('RAPIInterface', Config.RAPI_INTERFACE)
      self.set('RequestID', Config.RAVEN_PREFIX + SecureRandom.uuid.to_s)
      self.set('Timestamp', Time.now.gmtime.strftime("%Y-%m-%dT%H:%M:%S.000Z"))
    end  

    def set(key, value)
      @values[key] = value.to_s
    end

    def signature
      data = Config.RAVEN_USERNAME + self.get('Timestamp') + self.get('RequestID')
      if self.operation == 'submit'
        data = data + self.get('PymtType', 'PaymentType') + (self.get('Amount') + self.get('Currency', 'CurrencyCode')).to_s
      elsif self.operation == 'closefile'
        data = data + self.get('Filename')
      elsif self.operation == 'void'
        data = data + self.get('TrackingNumber')
      elsif self.operation == 'hello'
        data = Config.RAVEN_USERNAME  
      end  
      h = Digest::HMAC.hexdigest(data, Config.RAVEN_SECRET, Digest::SHA1)
    end

    def send
      self.set('Signature', self.signature)
      @ravenRequestString = URI::encode(self.values.to_s)

      (httpResponseError, responseData) = self.postRequest
    end

    def postRequest
      responseData = nil
      httpResponseError = nil
      
      uri = (Config.RAVEN_GATEWAY + '/' + self.operation + self.ravenRequestString)
      respondeData = open(uri)
      return respondeData
    end    
    
    #
    # Sends the actual request once all the required parameters have been set.
    # If required values are not set, it will throw an Exception listing the
    # missing values.
    #
    # @throws    RavenNoResponseException if inquiry must be made
    # @throws    RavenAuthentication if the response could be determined to 
    #   originate with Raven
    # @returns    RavenResponse object
    #
    # def send(self):
    
    #     self.set('Signature', self.signature())
    #     self.ravenRequestString = urllib.urlencode(self.values)
    #     self.log('Request string: ' + self.ravenRequestString)
        
    #     (httpResponseError, responseData) = self.postRequest()
        
    #     return RavenResponse(httpResponseError, responseData, self.operation)
              
  end 
end 


