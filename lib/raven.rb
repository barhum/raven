require 'config.rb'
require 'digest/hmac'
require 'net/http'
require 'cgi'
require 'yaml'


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

  class RavenConfig
    include Singleton
    attr_reader :user, :secret, :gateway, :prefix, :raven_debug, :rapi_version, :rapi_interface

    def setUser(user)
      @user = user
    end  

    def setSecret(secret)  
      @secret = secret
    end

    def setGateway(gateway)  
      @gateway =  gateway
    end

    def setPrefix(prefix)
      @prefix = prefix
    end

    def setRavenDebug(debug)
      @raven_debug = debug
    end

    def rapi_version   
      @rapi_version =  2
    end

    def rapi_interface
      @rapi_interface = 'rails0.1'
    end
  end 

  class Raven
    attr_reader :values, :operation, :ravenConfig

    def initialize(operation)
      @values = {}
      if !self.ravenOperations.include?(operation.to_s)
        raise RavenNoSuchOperationException("#{operation} is an unsupported operation.")
      end
      @operation = operation
      @ravenConfig = RavenConfig.new         
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

    def log(message)
      if (RavenConfig.raven_debug == 'on')
          print "<span style=\'background-color:orange\'>RAVEN: #{message}</span><br />'\n"
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
      self.set('UserName', @ravenConfig.user)
      self.set('RAPIVersion', @ravenConfig.rapi_version)
      self.set('RAPIInterface', @ravenConfig.rapi_interface)
      self.set('RequestID', @ravenConfig.prefix + SecureRandom.uuid.to_s)
      self.set('Timestamp', Time.now.gmtime.strftime("%Y-%m-%dT%H:%M:%S.000Z"))
    end  

    def set(key, value)
      @values[key] = value.to_s
    end

    def signature
      data = @ravenConfig.user + self.get('Timestamp') + self.get('RequestID')
      if self.operation == 'submit'
        data = data + self.get('PymtType', 'PaymentType') + (self.get('Amount') + self.get('Currency', 'CurrencyCode')).to_s
      elsif self.operation == 'closefile'
        data = data + self.get('Filename')
      elsif self.operation == 'void'
        data = data + self.get('TrackingNumber')
      elsif self.operation == 'hello'
        data = raven_config['user']  
      end  
      h = Digest::HMAC.hexdigest(data, @ravenConfig.secret, Digest::SHA1)
    end

    def send
      self.set('Signature', self.signature)
      params = ""
        
      self.values.each do |k, v| 
        if v
          params = params + "&#{k.to_s}=#{v.to_s}"
        end   
      end  
      @ravenRequestString = params
      
      httpResponseError, responseData = self.postRequest
      return RavenResponse.new(httpResponseError, responseData, self.operation)

    end

    def postRequest
      responseData = nil
      httpResponseError = nil
      uri = URI.parse(@ravenConfig.gateway + '/' + self.operation)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/x-www-form-urlencoded' })
      res.body = self.ravenRequestString
      
      begin
        response = http.request(res)
        if response.code == "200"
          responseData = response.body
        else
          httpResponseError = response.code
        end  
      rescue SocketError
        httpResponseError = "404"
      end  

      return httpResponseError, responseData
    end   
  end

  class RavenResponse < Raven
    attr_reader :ravenResponseString

    def initialize(httpResponseError, ravenResponseData, operation)
      super(operation)
      @ravenResponseString = ravenResponseData.to_s 
      self.setHttpHeader(httpResponseError)

      if self.get('httpStatus') == '200'
        self.log('Received HTTP response 200')
        self.parseResponse
      elsif self.get('httpStatus') == '500'
        self.log('Received HTTP response 500: Request may or may not have been processed, inquire.')     
        raise RavenNoResponseException('inquire again')
      else
        self.log('Received HTTP response ' + self.get('httpStatus'))
      end       
    end 

    def setHttpHeader(httpResponseError)    
      if (httpResponseError == nil)
        self.values['httpStatus'] = '200'
      else
        self.values['httpStatus'] = httpResponseError
      end 
    end

    def getRequestResult
      if (self.get('httpStatus') == '500')
        return 'serverError'
      else
        return self.get('RequestResult')
      end     
    end 

    def parseResponse   
      paramAndReportPairs = self.ravenResponseString.split('\r', 1)
      self.setResponseParameters(paramAndReportPairs[0])
      if paramAndReportPairs.length == 2
        self.setReportParameters(paramAndReportPairs[1])
      end  
      self.authenticate
    end
    
    def setResponseParameters(responseParamData)
      paramPairs = CGI::parse(responseParamData)
      paramPairs.each do |k, v|
        self.values[k] = v[0]
      end
    end

    def setReportParameters(reportData)
      self.values['Report'] = reportData
    end  

    def authenticate
      if (self.verificationSignature != self.get('Signature'))
        raise RavenAuthenticationException.new('Invalid Raven signature')
      end
    end

    def verificationSignature
      data = @ravenConfig.user + self.get('Timestamp').to_s + self.get('RequestID').to_s    
      h = Digest::HMAC.hexdigest(data, @ravenConfig.secret, Digest::SHA1).to_s      
    end       
  end               
end 


