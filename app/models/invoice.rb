class Invoice < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  has_many :invoice_items
  has_many :transactions

  # scope :filter_by_status, ->(status) { where(status: status) if status.present? }
  # above is the sugary way. I think maybe it is best to use the more standard, easily understood way for this
  # project maybe. (the one just below)

  def self.filter_by_status(status)
    where(status: status)
  end
end