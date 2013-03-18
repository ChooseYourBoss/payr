class Payr::BillsController < ApplicationController
  before_filter :check_response, except: [:pay, :failure, :ipn, :cancelled]
  before_filter :check_ipn_response, only: [:ipn]

  def pay
    @bill = Payr::Bill.new(buyer_id: params[:buyer][:id], 
                           amount: params[:total_price], 
                           article_id: params[:article_id],
                           state: Payr::Bill::UNPROCESSED,
                           bill_reference: params[:bill_reference])
    @payr = Payr::Client.new
    if @bill.save
      @paybox_params = @payr.get_paybox_params_from command_id: @bill.id, 
                                                    buyer_email: params[:buyer][:email], 
                                                    total_price: params[:total_price],
                                                    callbacks:  { 
                                                                  paid: payr_bills_paid_url, 
                                                                  refused: payr_bills_refused_url,   
                                                                  cancelled: payr_bills_cancelled_url,
                                                                  ipn: payr_bills_ipn_url
                                                                }
    end
  end

  def paid
    change_status params[:ref], Payr::Bill::PAID
  end

  def refused
    change_status params[:ref], Payr::Bill::REFUSED, params[:error]
  end

  def cancelled
    change_status params[:ref], Payr::Bill::CANCELLED, params[:error]
  end

  def ipn
    if params[:error] == Payr::Bill::NO_ERROR
      change_status params[:ref], Payr::Bill::PAID
      @bill.update_attribute(:error_code, Payr::Bill::NO_ERROR)
    else
      @bill = Payr::Bill.find(params[:ref])
      @bill.update_attribute(:error_code, params[:error])
    end
    render nothing: true, :status => 200, :content_type => 'text/html'
  end

  def failure
    change_status params[:ref], Payr::Bill::SIGN_ERROR, params[:error]
  end

  protected
  def change_status id, status, error=nil
    @bill = Payr::Bill.find(id)
    @bill.update_attribute(:state, status)
    @bill.update_attribute(:error_code, error) unless error.nil?
  end

end