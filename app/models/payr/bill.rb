class Payr::Bill < ActiveRecord::Base
  attr_accessible :amount, :article_id, :buyer_id, :state
end
