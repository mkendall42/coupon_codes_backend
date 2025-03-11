class Invoice < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :coupon, optional: true            #Foreign key allowed to be null (or valid id)

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }   #Hopefully this works correctly!

  # scope :filter_by_status, ->(status) { where(status: status) if status.present? }
  # above is the sugary way. I think maybe it is best to use the more standard, easily understood way for this
  # project maybe. (the one just below)

  def self.filter_by_status(status)
    where(status: status)
  end

  def set_status(new_status)
    # binding.pry
    #NOTE: why is the 'self' required here?  Something specific to Rails?
    self.status = new_status
  end
end