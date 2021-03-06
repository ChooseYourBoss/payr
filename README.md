# Payr : paybox system paiement made easy

## Installation

Add the gem payr to your Gemfile
```ruby
	gem "payr"
```

Then in your terminal

```sh
$ > rails generate payr:install
		create  db/migrate/20121016122427_create_bills_table.rb
		create  config/initializers/payr.rb
```
This should copy a migration file and the initializer payr.rb.

fill config/initializers/payr.rb with your own values coming from the paybox website 
you should always use different values for your pre production/production environements.

```sh
$ > rake db:migrate

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

	config.callback_values = { amount:"m", ref:"r", auto:"a", error:"e", signature:"k" }

	# Optionnal config : if not null, choose on behalf of the user the type of paiement. 
	# EX: "CARTE". Look at the paybox documentation for more
	#config.typepaiement = "CARTE"
	
	# Optionnal config : if not null, choose on behalf of the user the type of CARD. 
	# EX: "CB". Look at the paybox documentation for more
	#config.typecard = "CB"
end

```

### Routes And "AutoCustom" Controller =)

if you just want to use the helpers and don't care about the controllers and the bill model, skip this part 

You can use the routes by default by adding this to your config/routes.rb

```ruby
	payr_routes
```

This will generate 5 routes :

```sh
$ > rake routes
	payr_bills_pay          GET        /bills/pay(.:format)                payr/bills#pay
	payr_bills_pay          POST       /bills/pay(.:format)                payr/bills#pay
	payr_bills_paid         GET        /bills/paid(.:format)               payr/bills#paid
	payr_bills_refused      GET        /bills/refused(.:format)            payr/bills#refused
	payr_bills_cancelled    GET        /bills/cancelled(.:format)          payr/bills#cancelled
	payr_bills_ipn          GET        /bills/ipn(.:format)                payr/bills#ipn
```

And you will use the default controllers. 
We recommand to override the controllers thoug. For that, define a custom controller by doing :

```ruby
	payr_routes callback_controller: "paiement/callbacks" 
```

If you created a app/controllers/paiement/callbacks controller.

This will generate 5 routes :

```sh
$ > rake routes
	payr_bills_pay          GET        /paiement/callbacks/pay(.:format)                paiement/callbacks#pay
	payr_bills_pay          POST       /paiement/callbacks/pay(.:format)                paiement/callbacks#pay
	payr_bills_paid         GET        /paiement/callbacks/paid(.:format)               paiement/callbacks#paid
	payr_bills_refused      GET        /paiement/callbacks/refused(.:format)            paiement/callbacks#refused
	payr_bills_cancelled    GET        /paiement/callbacks/cancelled(.:format)          paiement/callbacks#cancelled
	payr_bills_ipn          GET        /paiement/callbacks/ipn(.:format)                paiement/callbacks#ipn
```

The controller could look something like this for example :

```ruby
	class	Paiement::CallbacksController < Payr::BillsController
		# if you use cancan
		skip_authorization_check
		# if you use devise 
		before_filter :authenticate_buyer!
		layout "simply_blue_simple"

		# But you can also rewrite the actions
		# to redirect to a specific action, for example :
		def paid
			super
			bill = Payr::Bill.find params[:ref]
			pack = Pack.find bill.article_id
			current_buyer.add_pack pack
			redirect_to new_offer_path
		end
	end
```




Basically, thoses actions do :
```ruby
#
# when calling payr_bills_pay_path (talking about that later) 
# will create a bill record with the article id, the buyer id
# the amount and the paiement status
# the render a transitionnal page which redirects to the paiement website
def pay
end

# Callbacks methods as defined in paybox system 
# changes the status of the bill
def paid
end
def refused
end
def cancelled
end
# server to server callback
def ipn
end
```

then into your view use the route :

```ruby
payr_bills_pay_path(article_id: pack.id, 
									  buyer: { email: current_recruiter.email, 
									  				 id: current_recruiter.id }, 
									  total_price: pack.price.to_i*100 )
```
You can also use the bill_reference parameter if you want to have a custom bill_parameter :
```ruby
payr_bills_pay_path(article_id: pack.id, 
									  buyer: { email: current_recruiter.email, 
									  				 id: current_recruiter.id }, 
									  total_price: pack.price.to_i*100,
									  bill_reference: "F00000001" )
```
This will call the bills#action and then redirect the user to the paybox paiement page.

# /!\ There is a security flaw in the above lines

While I'm correcting it, you MUST override the pay action, otherwise, someone could just make a get with the wanted amount and the wanted article.

a possible overriding would be this:

```ruby
class Paiement::CallbacksController < Payr::BillsController
	before_filter :authenticate_user!, except: [:ipn]
	def pay
	 	article = Pack.find params[:article_id]
    @bill = Payr::Bill.new(buyer_id: current_user.id,
                           amount: article.price,
                           article_id: params[:article_id],
                           state: Payr::Bill::UNPROCESSED,
                           bill_reference: params[:bill_reference])
    @payr = Payr::Client.new
    if @bill.save
      @paybox_params = @payr.get_paybox_params_from command_id: @bill.id, 
                                                    buyer_email: current_recruiter.email,
                                                    total_price: article.price,
                                                    callbacks:  { 
                                                                  paid: payr_bills_paid_url, 
                                                                  refused: payr_bills_refused_url,   
                                                                  cancelled: payr_bills_cancelled_url,
                                                                  ipn: payr_bills_ipn_url
																																}
	end                                                               
end
```


You can also override the views by creating the appropriate files :
```sh
$ > ls app/views/paiement/callbacks
		paid.html.haml
		refused.html.haml
		cancelled.html.haml
		failure.html.haml
```


To finish, you need to add this to the application.js

```javascript
//= require payr/bills
```

### Tests

If you wanna test your own callbacks, you can mock up the filters like this :
```ruby
before { Payr::Client.any_instance.should_receive(:check_response).and_return(true) } 
before { Payr::Client.any_instance.should_receive(:check_response_ipn).and_return(true) } 

```


# I Don't Care about your super CallbacksController and your Super Bill Model

## YEAH, I just want the backbone : form helpers, signature checker

Okay, this is possible :

- Don't use the rails generator payr:install

- copy the payr.rb file from the step above into the config/initializers folder.


Use the following helpers :
```ruby
# to check signature responses in your callback controllers
before_filter :check_response
before_filter :check_ipn_response

# To get all the paybox fields in a hash
@payr = Payr::Client.new
@paybox_params = @payr.get_paybox_params_from	command_id: bill.id, 
																							buyer_email: params[:buyer_email], 
																							total_price: params[:total_price],
																							callbacks:  { 
																														paid: callback_paid_url, 
																														refused: callback_refused_url,   
																														cancelled: callback_cancelled_url,
																														ipn: callback_ipn_url
																													}

# To generate the fields into the view 
# just the fields
paybox_hidden_fields @paybox_params
# the entire form
paybox_form submit_name, @paybox_params
```

### I WANNA HELP ?

For this no problem friend :
- fork
- add tests
- run tests

```sh
rake
````
- pull request

i'll gladly add your work =)

### TODO

- add helper "after_payment_path", "after_cancelled_path" etc that can be overrided to avoid to override BillsControllers
- improve documentation about what BillController does

This project rocks and uses MIT-LICENSE.