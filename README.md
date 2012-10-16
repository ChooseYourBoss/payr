## WARNING

== Repo not stable yet.

# Payr : paybox system paiement made easy

## Installation

```ruby
gem "payr"

```

Then in your terminal

```sh
	rails generate payr:install
	create  db/migrate/20121016122427_create_bills_table.rb
  create  config/initializers/payr.rb
```
This should copy a migration file and the initializer payr.rb.

fill config/initializers/payr.rb with your own values coming from the paybox website 
you should always use different values for your pre production/production environements.

```sh
rake db:migrate
==  CreateBillsTable: migrating ===============================================
-- create_table(:bills)
		NOTICE:  CREATE TABLE will create implicit sequence "bills_id_seq" for serial column "bills.id"
		NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "bills_pkey" for table "bills"
   	-> 0.0246s
==  CreateBillsTable: migrated (0.0247s) ======================================

```

## Setup

### Paybox System
```ruby
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

	config.callback_route = nil
	config.callback_refused_route = nil
	config.callback_cancelled_route = nil

	config.ipn_route = nil

	config.callback_values = { amount:"m", ref:"r", auto:"a", error:"e", signature:"k" }


	# Optionnal config : if not null, choose on behalf of the user the type of paiement. 
	# EX: "CARTE". Look at the paybox documentation for more
	#config.typepaiement = "CARTE"
	
	# Optionnal config : if not null, choose on behalf of the user the type of CARD. 
	# EX: "CB". Look at the paybox documentation for more
	#config.typecard = "CB"
end

```

### Routes
You can use the routes by default by adding this to your config/routes.rb

```ruby
payr_routes callback_controller: "paiement/callbacks" 
```

```ruby
payr_routes callback_controller: "paiement/callbacks" 
```

then into your view use the route :

```ruby
payr_bills_pay_path(article_id: pack.id, buyer: {email: current_recruiter.email, id: current_recruiter.id }, total_price: pack.price.to_i*100)
```
This will call the bills controller


paybox_hidden_fields @paybox_params
form_tag(Payr.paybox_url)




//= require payr/bills




class	Paiement::CallbacksController < Payr::BillsController
	skip_authorization_check
	layout "simply_blue_simple"
end


This project rocks and uses MIT-LICENSE.