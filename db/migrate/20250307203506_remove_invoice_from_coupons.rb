class RemoveInvoiceFromCoupons < ActiveRecord::Migration[7.1]
  def change
    remove_reference :coupons, :invoice, null: false, foreign_key: true
  end
end
