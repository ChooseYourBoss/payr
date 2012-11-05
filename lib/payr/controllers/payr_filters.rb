module Payr
	module PayrFilters
		extend ActiveSupport::Concern
		
		def check_response
			unless Payr::Client.new.check_response(request.url)
				redirect_to payr_bills_failure_path
				return
			end
		end
		# /paiement/callbacks/ipn?amount=70564&ref=4&auto=XXXXXX&error=00000&signature=D433ko4%2FCWgSsmh0SkoLGHFSKau9K6DDlRLsEu%2FP8OnydVG8r3XJLfsIp2odPOvJ%2FTQTh3v16Q9H%2BR%2BO3N6NRoaotoOl4uO0qzI7kSziyJkocpJXOiyg0jp%2FDg2%2FTmlQCxsk8eFxoYNokZd4tZ2hS1ECXeFMrXeg5pVLfsdPXDs%3D
		def check_ipn_response
			unless Payr::Client.new.check_response_ipn(params)
				redirect_to payr_bills_failure_path
				return
			end
		end
	end
end