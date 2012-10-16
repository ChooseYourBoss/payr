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
			unless Payr::Client.new.check_response_ipn(params)
				redirect_to payr_bills_failure_path
				return
			end
		end
	end
end