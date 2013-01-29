require 'spec_helper'

describe Payr::Client do
	before do
		Payr.setup do |c|
			c.site_id = 1999888
			c.rang = 32
			c.paybox_id = 2
			c.secret_key = "super_secret_monkey_passphrase"
		end
	end
	after do
		Payr.setup do |c|
			c.site_id = nil
			c.rang = nil
			c.paybox_id = nil
			c.secret_key = nil
			c.callback_values = { amount:"m", ref:"r", auto:"a", error:"e", signature:"k" }
		end
	end
  let(:payr) { Payr::Client.new }
  
  describe "get_paybox_params_from" do
    context "when parameters are false or incomplete" do
      let(:params) { {paybox_return_values: {stuff: "YAY"}, command_id: "cmd", total_price: 1000 }}

      it "should raise an argumentException" do
      	expect {	payr.get_paybox_params_from params }.to raise_error(ArgumentError)
      end
    end
    context "when parameters are complete" do
      let(:params) { {callbacks: {paid: "YAY", refused: "YAY", cancelled: "YAY"}, buyer_email: "monkey@payr.com", command_id: "cmd", total_price: 1000 }}
    
      before { @returned_hash = payr.get_paybox_params_from params}
      subject { @returned_hash }
      its(:keys) { should include :pbx_identifiant, :pbx_rang, :pbx_total, :pbx_devise, :pbx_cmd, :pbx_retour, :pbx_porteur, :pbx_hash, :pbx_time, :pbx_hmac }
    end
    context "when parameters are complete and using the option params" do
      let(:params) { {options: {pbx_option: "option"}, callbacks: {paid: "YAY", refused: "YAY", cancelled: "YAY"}, buyer_email: "monkey@payr.com", command_id: "cmd", total_price: 1000 }}
    
      before { @returned_hash = payr.get_paybox_params_from params}
      subject { @returned_hash }
      its(:keys) { should include :pbx_option, :pbx_identifiant, :pbx_rang, :pbx_total, :pbx_devise, :pbx_cmd, :pbx_retour, :pbx_porteur, :pbx_hash, :pbx_time, :pbx_hmac }
    end
    context "when very specific parameters" do
    	let(:params) { {callbacks: {paid: "YAY", refused: "YAY", cancelled: "YAY"}, buyer_email: "coste.vincent@gmail.com", command_id: "123456", total_price: 10000 }}
      before do
				Payr.setup do |c|
					c.site_id = 1999888
					c.rang = 32
					c.paybox_id = 110647233
					c.secret_key = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
				end
			end
			before { 
				Timecop.freeze(Time.utc(2012, 10, 11, 12, 51, 45)) do
					@returned_hash = payr.get_paybox_params_from params
				end
			}
      subject { @returned_hash }

      it "should have a specific hmac" do
      	@returned_hash[:pbx_hmac].should eql("5CD602D3C014B03573B842CFBC048E8B39E9FE86515B4F45834B77CC3EDCC3951BA43C354F155BA21422C14724B7D7F403621483FAFE039D5913A287277D483F")
      end

    end

  end

	describe ".generate_hmac" do
	  before do
	  	Payr.setup do |c|
	  		c.secret_key = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
	  	end
  	 	@hmac = payr.send(:generate_hmac, "PBX_SITE=1999888&PBX_RANG=32&PBX_IDENTIFIANT=1686319&PBX_TOTAL=10000&PBX_DEVISE=978&PBX_CMD=123456&PBX_PORTEUR=coste.vincent@gmail.com&PBX_RETOUR=Mt:M;Ref:R;Auto:A;Erreur:E&PBX_HASH=SHA512&PBX_TIME=2012-10-10T17:06:17Z&commit=Save changes") 
	  end
	  subject { @hmac }
	  it { should eql("91B131D535FA671A2A09C7C4CE175044854EB7C6414A5F576D006D3336D4C4B35789EE1E51267CF0B0313364D069BE80241769B00F7D99259FE81354A4482759") }
	end
	describe ".to_base_params" do

		subject { @field }
		before do
			Payr.setup do |config| 
				config.hash = :sha512
				config.currency = :euro
			end
		end

		context "when base params" do
		  before { @field = payr.send(:to_base_params, :pbx_site=>1999888, :pbx_rang=>32, :pbx_identifiant=>2, :pbx_total=>1000, :pbx_devise=>978, :pbx_cmd=>"TEST Paybox", :pbx_porteur=>"test@paybox.com", :pbx_retour=>"Mt:M;Ref:R;Auto:A;Erreur:E", :pbx_hash=>:SHA512, :pbx_time=>"2011-02-28T11:01:50+01:00") }
			it { should match(/^PBX_SITE=1999888&PBX_RANG=32&PBX_IDENTIFIANT=2&PBX_TOTAL=1000&PBX_DEVISE=978&PBX_CMD=TEST Paybox&PBX_PORTEUR=test@paybox.com&PBX_RETOUR=Mt:M;Ref:R;Auto:A;Erreur:E&PBX_HASH=SHA512&PBX_TIME=2011-02-28T11:01:50\+01:00$/) }
		end
		context "when very specific params" do
		  before { @field = payr.send(:to_base_params, :pbx_site=>1999888, :pbx_rang=>32, :pbx_identifiant=>110647233, :pbx_total=>10000, :pbx_devise=>978, :pbx_cmd=>"123456", :pbx_porteur=>"coste.vincent@gmail.com", :pbx_retour=>"Mt:M;Ref:R;Auto:A;Erreur:E", :pbx_hash=>:SHA512, :pbx_time=>"2012-10-11T12:51:45Z") }
			it { should match(/^PBX_SITE=1999888&PBX_RANG=32&PBX_IDENTIFIANT=110647233&PBX_TOTAL=10000&PBX_DEVISE=978&PBX_CMD=123456&PBX_PORTEUR=coste.vincent@gmail.com&PBX_RETOUR=Mt:M;Ref:R;Auto:A;Erreur:E&PBX_HASH=SHA512&PBX_TIME=2012-10-11T12:51:45Z$/) }
		end
		context "when non base params" do
		  before { @field = payr.send(:to_base_params, :pbx_site=>1999888, :pbx_rang=>32, :pbx_identifiant=>2, :pbx_total=>1000, :pbx_devise=>978, :pbx_cmd=>"TEST Paybox", :pbx_porteur=>"test@paybox.com", :pbx_retour=>"Mt:M;Ref:R;Auto:A;Erreur:E", :pbx_hash=>:SHA512, :pbx_time=>"2011-02-28T11:01:50+01:00", pbx_typepaiement: "CARTE", pbx_typecarte: "CB") }
			it { should match(/^PBX_SITE=1999888&PBX_RANG=32&PBX_IDENTIFIANT=2&PBX_TOTAL=1000&PBX_DEVISE=978&PBX_CMD=TEST Paybox&PBX_PORTEUR=test@paybox.com&PBX_RETOUR=Mt:M;Ref:R;Auto:A;Erreur:E&PBX_HASH=SHA512&PBX_TIME=2011-02-28T11:01:50\+01:00&PBX_TYPEPAIEMENT=CARTE&PBX_TYPECARTE=CB$/) }
		end

	end
	
	describe ".build_return_variables" do
	  before { @return_variables = payr.send(:build_return_variables, mt:"m", ref:"r", auto:"a", erreur:"e") }
	  subject { @return_variables }
	  it { should eql("mt:M;ref:R;auto:A;erreur:E")}
	end
	describe ".check_response_verify" do
		let(:digest) {OpenSSL::Digest::SHA1.new }
		let(:pkey) { OpenSSL::PKey::RSA.new(1024) }
		let(:signature) { pkey.sign(digest, "params1=1&params2=2") }
		before { @verified =  payr.send(:check_response_verify, "params1=1&params2=2", signature, pkey.public_key)}
		subject { @verified } 
	  it { should be_true }
	end

	describe ".re_build_ipn_query" do
		context "when one params" do
		  before do 
				Payr.setup { |config| config.callback_values = { params1:1 }   }
				@query =  payr.send(:re_build_ipn_query, { params1:1, params2:2, signature:"1"} )
			end
			subject { @query } 
	  	it { should eq("params1=1") }
		end
		context "when two params" do
		  before do 
				Payr.setup { |config| config.callback_values = { params1:1, params3:3 }   }
				@query =  payr.send(:re_build_ipn_query, { params1:1, params2:2, params3:3, signature:"1"} )
			end
			subject { @query } 
	  	it { should eq("params1=1&params3=3") }
		end

	end
	describe ".re_build_query" do
		let(:params){ "?params1=1&params2=2&signature=XXXX" }
	  before { @query = payr.send(:re_build_query, params) }
	  subject { @query }
	  it {should eql("params1=1&params2=2")}
	end
	describe ".get_signature" do
		let(:params){ "?params1=1&params2=2&signature=XXXX" }
	  before { @query = payr.send(:get_signature, params) }
	  subject { @query }
	  it {should eql("XXXX")}
	end

	describe ".check_server_availability" do
		context "when URL is available" do
			before do 
				FakeWeb.register_uri(:get, "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi", :status => ["200", "OK"])
				@available = payr.send :check_server_availability, "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi"	
			end
			subject { @available }
	  	it { should be_true }
		end
		context "when URL is no available" do
			before do 
				FakeWeb.register_uri(:get, "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi", :status => ["404", "NOT FOUND"])
				@available = payr.send :check_server_availability, "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi"	
			end
			subject { @available }
	  	it { should be_false }
		end
	end

	describe ".select_server_url" do
	  before do 
	  	Payr.setup { |p| 
	  		p.paybox_url = "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi"
	  		p.paybox_url_back_one = "https://preprod-tpeweb.paybox.com/cgi/okay.cgi"
	  		p.paybox_url_back_two = "https://preprod-tpeweb.paybox.com/cgi/notokay.cgi"
	  	}
			FakeWeb.register_uri(:get, "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi", :status => ["404", "NOT FOUND"])
			FakeWeb.register_uri(:get, "https://preprod-tpeweb.paybox.com/cgi/notokay.cgi", :status => ["404", "NOT FOUND"])
			FakeWeb.register_uri(:get, "https://preprod-tpeweb.paybox.com/cgi/okay.cgi", :status => ["200", "NOT FOUND"])
			@url = payr.select_server_url
		end
		subject { @url }
		it { should eq("https://preprod-tpeweb.paybox.com/cgi/okay.cgi")}
	end

end