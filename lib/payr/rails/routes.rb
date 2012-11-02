module ActionDispatch::Routing
	class Mapper
		def payr_routes(options={})
				if options && options[:callback_controller]
					get "#{options[:callback_controller]}/pay", as: "payr_bills_pay"
					post "#{options[:callback_controller]}/pay", as: "payr_bills_pay"
				else
					get "payr/bills/pay", as: "payr_bills_pay"
					post "payr/bills/pay", as: "payr_bills_pay"
				end
			%w(paid refused cancelled ipn failure).each do |action|
				if options && options[:callback_controller]
					get "#{options[:callback_controller]}/#{action}", as: "payr_bills_#{action}"
				else
					get "payr/bills/#{action}", as: "payr_bills_#{action}"
				end
			end
		end
	end
end