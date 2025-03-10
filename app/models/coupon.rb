class Coupon < ApplicationRecord
  has_one :invoice          #Remember: do NOT destroy invoice if coupon destroyed!
  belongs_to :merchant

  def times_used
    return 3      #Just for testing right now, adjust later!
  end

#   #Verify that the code is unique before proceeding - should this be instance or class method?
#   #NOTE: make this a before_create (or whatever) callback!  Should work...
#   def verify_unique_code
#     #Check DB for all coupons' codes.
#     #QUESTION: does code need to truly be unique, or just for a given merchant?
#     return true if !Coupon.find_by(code: code)
#     return false
#   end

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
# end
