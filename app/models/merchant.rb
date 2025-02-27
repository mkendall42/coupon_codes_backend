class Merchant < ApplicationRecord
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  #customer

  def self.sorted_by_age
    order(created_at: :desc)
  end

  def self.has_returned_items
    joins(:invoices).where( invoices: { status: "returned" })
  end
end