class Payr::Bill < ActiveRecord::Base
  UNPROCESSED = "unprocessed"
  PAID = "paid"
  REFUSED = "refused"
  CANCELLED = "cancelled"
  SIGN_ERROR = "bad_signature"
  NO_ERROR = "00000"
  
  attr_accessible :amount, :article_id, :buyer_id, :state, :bill_reference
end
