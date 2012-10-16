Payr.setup do |config|
	# Put the  merchant site ID found on the paybox website
	#config.site_id = 1999888

	# Put the merchant rang found on the paybox website
	#config.rang = 32
	
	# Put the merchant paybox ID found on the paybox website
	#config.paybox_id = 1686319
	
	# Put the secret key for the hmac pass found on the paybox website
	#config.secret_key = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"

	# Put the hash algorithm
	# Possible values are :SHA256 :SHA512 :SHA384 :SHA224 
	config.hash = :sha512
	
	# The currency 
	# possible values :euro :us_dollar
	config.currency = :euro 
	
	config.paybox_url = "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi"
	# config.paybox_url_back_one = nil
	# config.paybox_url_back_two = nil

	#
	# Those are used if you want to totally redo the controllers and 
	# Just use the helpers
	# 
	# config.callback_route = nil
	# config.callback_refused_route = nil
	# config.callback_cancelled_route = nil
	
	# config.ipn_route = nil

	config.callback_values = { amount:"m", ref:"r", auto:"a", error:"e", signature:"k" }


	# Optionnal config : if not null, choose on behalf of the user the type of paiement. 
	# EX: "CARTE". Look at the paybox documentation for more
	#config.typepaiement = "CARTE"
	
	# Optionnal config : if not null, choose on behalf of the user the type of CARD. 
	# EX: "CB". Look at the paybox documentation for more
	#config.typecard = "CB"
end