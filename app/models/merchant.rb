class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items
  #customer
  
  def self.sorted_by_age
    Merchant.order(created_at: :desc)
  end
end