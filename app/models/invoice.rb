class Invoice < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  has_many :invoice_items
  has_many :transactions

  scope :filter_by_status, ->(status) { where(status: status) if status.present? }
end