class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items
  #customer
end