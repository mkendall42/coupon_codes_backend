class Coupon < ApplicationRecord
  has_many :invoices          #Remember: do NOT destroy invoice(s) if coupon destroyed!
  #NOTE: the above should probably be 'has_many', since it can be used again and again...
  belongs_to :merchant

  def times_used
    #Determine number of times this coupon has been used.
    #We'll define 'used' as any invoice attached to it (though technically it could wait until 'shipped')

    #This needs to find this coupon's connection to ALL invoices
    Invoice.where(coupon_id: self.id).count

    # return 3      #Just for testing right now, adjust later!
  end

  def set_status(new_status)
    #If setting inactive->active, must check that < 5 are already active for merchant
    #If setting active->inactive, must check that there are no associated pending invoice(s)

    #AH CRAP; 'render' doesn't exist outside of controller scope.  This makes it tougher...
    #Could either return true/false and process accordinately, but this would miss some granularity on the nature of the problem
    #OR, just move all this to the controller (except AR queries, keep 'em in models)

    # binding.pry

    # if new_status == "active" && status == false
    #   if merchant.find_number_active_coupons >= 5
    #     render json: { data: "too many active already yo" }, status: :unprocessable_entity
    #   else
    #     #Activate it!
    #     render json: { data: "hi" }
    #   end
    # elsif new_status == "inactive" && status == true
    #   if invoices.where(status: "packaged").count > 0
    #     render json: { data: "Ya can't deactivate it 'til it's processed, man!" }, status: :unprocessable_entity
    #   else
    #     #Deactivate it!
    #     render json: { data: "hi" }
    #   end
    # else
    #   #Either nothing was changed, or got a bad input string here, generate an appropriate error
    #   render json: { data: "uh oh, hit the else" }, status: 404
    # end

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

  def pending_invoices?
    invoices.where(status: "packaged").count > 0
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
