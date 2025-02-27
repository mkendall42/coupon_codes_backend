class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items
  #customer

  def self.sorted_by_age
    order(created_at: :desc)
  end

  def self.has_returned_items
    joins(:invoices).where( invoices: { status: "returned" })
  end
end