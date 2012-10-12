require 'spec_helper'

describe Payr::PayrHelpers do
  before(:each) do
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
		end
	end
	describe "#paybox_hidden_fields" do
  	it "should return hidden fields for paybox" do
  		fields = ""
  		Timecop.freeze(Time.new(2011, 02, 28, 11, 01, 50,"+01:00")) do
  			fields = paybox_hidden_fields({:pbx_site=>1999888, :pbx_rang=>32, :pbx_identifiant=>2, :pbx_total=>1000, :pbx_devise=>978, :pbx_cmd=>"cmd", :pbx_porteur=>"monkey@payr.com", :pbx_retour=>"Mt:M;Ref:R;Auto:A;Erreur:E", :pbx_hash=>:SHA512, :pbx_time=>"2012-10-09T21:47:54+02:00", :pbx_hmac=>"3AB1B6B739C163D3396549C4F8F6E9F9CFB846C0945BA9D8CC91D93D4D9F61E65BF71AD0B9B3665373A437DF698BCC51EB3762F1C6E625558E5704F9DDA55ED9"})
  		end
  		fields.should eq('<input id="PBX_SITE" name="PBX_SITE" type="hidden" value="1999888" /><input id="PBX_RANG" name="PBX_RANG" type="hidden" value="32" /><input id="PBX_IDENTIFIANT" name="PBX_IDENTIFIANT" type="hidden" value="2" /><input id="PBX_TOTAL" name="PBX_TOTAL" type="hidden" value="1000" /><input id="PBX_DEVISE" name="PBX_DEVISE" type="hidden" value="978" /><input id="PBX_CMD" name="PBX_CMD" type="hidden" value="cmd" /><input id="PBX_PORTEUR" name="PBX_PORTEUR" type="hidden" value="monkey@payr.com" /><input id="PBX_RETOUR" name="PBX_RETOUR" type="hidden" value="Mt:M;Ref:R;Auto:A;Erreur:E" /><input id="PBX_HASH" name="PBX_HASH" type="hidden" value="SHA512" /><input id="PBX_TIME" name="PBX_TIME" type="hidden" value="2012-10-09T21:47:54+02:00" /><input id="PBX_HMAC" name="PBX_HMAC" type="hidden" value="3AB1B6B739C163D3396549C4F8F6E9F9CFB846C0945BA9D8CC91D93D4D9F61E65BF71AD0B9B3665373A437DF698BCC51EB3762F1C6E625558E5704F9DDA55ED9" />')
  	end
	end

end