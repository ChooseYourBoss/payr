class Payr::Bill < ActiveRecord::Base
  attr_accessible :amount, :article_id, :buyer_id, :state, :bill_reference
end
