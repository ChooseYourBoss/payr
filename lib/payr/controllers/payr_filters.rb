module Payr
	module PayrFilters
		extend ActiveSupport::Concern
		
		def check_response params
			Payr::Client.new.check_response params
		end
	end
end