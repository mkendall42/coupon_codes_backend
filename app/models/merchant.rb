class Merchant < ApplicationRecord
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers, through: :invoices
  has_many :coupons

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

  def get_coupons_by_status(status)
    #NOTE: status = true is active, false is inactive
    coupons.where(status: status)
  end

  def find_number_active_coupons
    coupons.where(status: true).count
  end

  def coupons_count
    coupons.count
  end

  def invoice_coupon_count
    #Total number of merchant's invoices that used one of the coupons
    invoices.where.not(coupon_id: nil).count
  end
end