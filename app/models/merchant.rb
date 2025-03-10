class Merchant < ApplicationRecord
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers, through: :invoices
  has_many :coupons                         #Set up destroy callback?  Or keep 'em?

  def self.sorted_by_age
    order(created_at: :desc)
  end

  def self.has_returned_items
    joins(:invoices).where( invoices: { status: "returned" })
  end

  def item_count
    items.count
  end

  def self.find_by_name_string(search_string)
    where("name ILIKE ?", "%#{search_string}%").order(:name)
  end

  def find_number_active_coupons
    #NOTE: status = true is active, false is inactive (should've named table column active_status)
    # Merchant.find(current_merchant_id).coupons.where(status: true).count
    coupons.where(status: true).count
  end
end