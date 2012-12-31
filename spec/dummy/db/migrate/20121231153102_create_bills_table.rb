class CreateBillsTable < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.integer :buyer_id
      t.integer :article_id
      t.integer :amount
      t.string :state
      t.string :error_code
      t.string :bill_reference
      t.timestamps
    end
  end
end
