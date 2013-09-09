module ActionDispatch::Routing
  class Mapper
    def payr_routes(options={})
      if options && options[:callback_controller]
        match "#{options[:callback_controller]}/pay", as: "payr_bills_pay", via: [:get, :post]
      else
        match "payr/bills/pay", as: "payr_bills_pay", via: [:get, :post]
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
