module Payr
	module PayrFilters
		extend ActiveSupport::Concern
		
		def check_response
			unless Payr::Client.new.check_response(request.url)
				redirect_to payr_bills_failure_path
				return
			end
		end
		def check_ipn_response
			# TODO use : unless Payr::Client.new.check_response_ipn(params) 
			unless Payr::Client.new.check_response_ipn(request.url)
				redirect_to payr_bills_failure_path
				return
			end
		end
	end
end