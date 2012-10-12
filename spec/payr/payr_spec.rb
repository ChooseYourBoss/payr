require 'spec_helper.rb'

describe Payr do
	describe "module attributes" do
		its(:site_id) { should be_nil }
		its(:rang) { should be_nil }
		its(:paybox_id) { should be_nil }
		its(:secret_key) { should be_nil }
		its(:currency) { should eq(:euro) }
		its(:hash) { should eq(:sha512) }
	end
	
	describe ".setup" do
	  it "should return self" do
	  	Payr.setup do | config |
	  		config.should eq(Payr)
	  	end
	  end
	end

end