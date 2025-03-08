class Coupon < ApplicationRecord
  has_one :invoice          #Remember: do NOT destroy invoice if coupon destroyed!
  belongs_to :merchant

end