class Coupon < ApplicationRecord
  belongs_to :merchant

  # validates :name, :code, presence: true    #Causes a lot of grief in details for FactoryBot, etc.  Will activate if I get time to fully check it out...

  def times_used
    #Determine number of times this coupon has been used (define 'used' as any invoice attached to it, even though it may not have shipped)
    Invoice.where(coupon_id: self.id).count
  end

  def self.verify_unique_code(code)
    #Check DB for all coupons' codes.  For now, must be unique among ALL codes; later could just be unique per merchant
    return true if !find_by(code: code)
    return false
  end

  def pending_invoices?
    Invoice.where(coupon_id: self.id).where(status: "packaged").count > 0
  end

#   #Generate a new unique code - should this be instance or class method?
#   def generate_unique_code
#     #Useful for FactoryBot or if user later desires it (extension)
#     #LATER: append chars to indicate whether $ off or % off
#     character_list = ("A".."Z").to_a
#     character_list << ("0".."9").to_a
#     character_list = character_list.flatten
#     num_chars = 8

#     loop do
#       new_code = character_list.sample(num_chars).join("")
#       return new_code if verify_unique_code
#     end
#   end

end
