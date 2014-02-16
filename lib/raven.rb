require 'config'
require 'debugger'

module Raven
  class Raven
    attr_reader :values, :operation

    def initialize(operation)
      @values = {}
      if !self.ravenOperations.include?(operation.to_s)
        raise "Operation not supported"
      end
      @operation = operation         
    end

    def ravenOperations
      @ravenOperations = ['submit','closefile','response','void','hello','payments','events','status']
    end  
  end

  class RavenRequest < Raven
    def set(key, value)
      @values[key] = value.to_s
    end
  end 
end 


