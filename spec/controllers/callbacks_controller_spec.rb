require 'spec_helper'

# Test in dummy application
# routes data for test is in the dummy/config/routes.rb
describe CallbacksController do
  describe "methods added by initializer" do
    it { should respond_to :check_response }
    it { should respond_to :check_ipn_response }
  end

  describe "routes added by payr_for" do
    context "when not using routes by default" do
      before { get :pay, buyer: { email:"coste.vincent@gmail.com", id:1}, article_id:1, total_price: 89000  }
      subject { response }

      it { should be_success }
    end
  end


  describe ":before_filter.check_response" do
    context "when bad signature" do
      before do 
        Payr::Client.any_instance.should_receive(:check_response).and_return(false)
        get :paid, buyer: { email:"coste.vincent@gmail.com", id:1}, article_id:1, total_price: 89000, signature: "bad signature for sure" 
      end
      subject { response }
      it { should be_redirect }
    end
  end

  describe "GET pay" do
    it "should create a bill with with status 'unprocessed'" do
      expect{
        get :pay, buyer: { email:"coste.vincent@gmail.com", id:1}, article_id:1, total_price: 89000
      }.to change{Payr::Bill.count}.from(0).to(1)
    end
  end
  describe "callback methods" do
    let(:bill) { Payr::Bill.new(buyer_id: 1, 
                                amount: 100,
                                article_id: 1, 
                                state: "unprocessed").tap { |bill| bill.save } }
    
    subject { bill.reload }
    

    describe "get ipn" do
      before { Payr::Client.any_instance.should_receive(:check_response_ipn).and_return(true) } 
      context "when no error" do
        before { get :ipn, amount:"m", ref:bill.id, auto:"a", error:"00000", signature:"k" }
        its(:state) { should eql("paid") }
        it "response should be blank" do
          response.body.should be_blank
        end
      end
      context "when errors" do
        before { get :ipn, amount:"m", ref:bill.id, auto:"a", error:"00001", signature:"k" }
        its(:state) { should eql("unprocessed") }
        it "response should be blank" do
          response.body.should be_blank
        end

      end

    end
    describe "classic callbacks" do
      before {  Payr::Client.any_instance.should_receive(:check_response).and_return(true) }
      describe "GET paid" do
        before { get :paid, amount:"m", ref:bill.id, auto:"a", error:"e", signature:"k" }
        its(:state) { should eql("paid") }
      end
      
      describe "GET refused" do
        before { get :refused, amount:"m", ref:bill.id, auto:"a", error:"12", signature:"k" }
        its(:state) { should eql("refused") }
        its(:error_code) { should eql("12") }
      end

      describe "GET cancelled" do
        before { get :cancelled, amount:"m", ref:bill.id, auto:"a", error:"123", signature:"k" }
        its(:state) { should eql("cancelled") }
        its(:error_code) { should eql("123") }
      end
    end
 
  end

end



