Payr.setup do |config|
	# Put the  merchant site ID found on the paybox website
	# config.site_id = XXX

	# Put the merchant rang found on the paybox website
	# config.rang = XXX
	
	# Put the merchant paybox ID found on the paybox website
	# config.paybox_id = XXX
	
	# Put the secret key for the hmac pass found on the paybox website
	# config.secret_key = "super_secret_monkey_passphrase"

	# Put the hash algorithm
	# Possible values are :SHA256 :SHA512 :SHA384 :SHA224 
	config.hash = :sha512
	
	# The currency 
	# possible values :euro :us_dollar
	config.currency = :euro 
	
	# config.paybox_url = nil
	# config.paybox_url_back_one = nil
	# config.paybox_url_back_two = nil

	# Optionnal config : if not null, choose on behalf of the user the type of paiement. 
	# EX: "CARTE". Look at the paybox documentation for more
	#config.typepaiement = nil
	
	# Optionnal config : if not null, choose on behalf of the user the type of CARD. 
	# EX: "CB". Look at the paybox documentation for more
	#config.typecard = nil
end