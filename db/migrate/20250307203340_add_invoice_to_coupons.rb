class AddInvoiceToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_reference :coupons, :invoice, null: false, foreign_key: true
  end
end
