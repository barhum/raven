require 'config'
require 'debugger'

module Raven
	class Raven
		def initialize(operation)
			@values = {}
			if !self.ravenOperations.include?(operation.to_s)
				raise "Operation not supported"
			end         
		end

		def ravenOperations
			@ravenOperations = ['submit','closefile','response','void','hello','payments','events','status']
		end	 

		def values
			@values
		end	
	end

	class RavenRequest < Raven
		def set(key, value)
			@values[key] = value.to_s
		end
	end	
end	


