class Coupon < ApplicationRecord
  has_one :invoice          #Remember: do NOT destroy invoice if coupon destroyed!
  belongs_to :merchant

  def times_used
    #Determine number of times this coupon has been used.
    #We'll define 'used' as any invoice attached to it (though technically it could wait until 'shipped')

    #This needs to find this coupon's connection to ALL invoices
    Invoice.where(coupon_id: self.id).count

    # return 3      #Just for testing right now, adjust later!
  end

  # def find_number_active_coupons
  #   #NOTE: status = true is active, false is inactive (should've named table column active_status)
  #   # Merchant.find(current_merchant_id).coupons.where(status: true).count
  #   coupons.where(status: true).count
  # end

#   #Verify that the code is unique before proceeding - should this be instance or class method?
#   #NOTE: make this a before_create (or whatever) callback!  Should work...
  def self.verify_unique_code(code)
    #Check DB for all coupons' codes.  For now, must be unique among ALL codes; later could just be unique per merchant
    #Also, for now a class method, since it's hard to call on an object when it doesn't yet exist (i.e. when creating it)
    return true if !find_by(code: code)
    return false
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
