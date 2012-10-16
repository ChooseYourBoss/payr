module ActionDispatch::Routing
	class Mapper
		def payr_routes(options={})			
			["pay", "paid", "refused", "cancelled", "ipn", "failure"].each do |action|
				if options && options[:callback_controller]
					get   "#{options[:callback_controller]}/#{action}", as: "payr_bills_#{action}"
				else
					get   "payr/bills/#{action}", as: "payr_bills_#{action}"
				end
			end
		end
	end
end