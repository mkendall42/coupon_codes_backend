class Api::V1::Merchants::CouponsController < ApplicationController
  #Handles coupon related queries belonging to a merchant (hence the namespace)
  rescue_from ActiveRecord::RecordNotFound, with: :coupon_not_found

  def index
    #Find and render all coupons for merchant.
    #Will need to handle potential exceptions here

    # binding.pry

    #Filter results if query param specified
    #MOVE TO OBJECT MODEL SOON!!!
    merchant = Merchant.find(params[:merchant_id])

    if params[:filter_status] == "active"
      # binding.pry
      merchant_coupons = merchant.get_coupons_by_status(true)
      # merchant_coupons = Merchant.find(params[:merchant_id]).coupons.where(status: true)
    elsif params[:filter_status] == "inactive"
      merchant_coupons = merchant.get_coupons_by_status(false)
      # merchant_coupons = Merchant.find(params[:merchant_id]).coupons.where(status: false)
    else
      # merchant_coupons = Merchant.find(params[:id]).coupons
      merchant_coupons = merchant.coupons
    end

    #Will need a new serializer for this
    render json: CouponSerializer.new(merchant_coupons)

  end

  def show
    #Find and render specified coupon for specified merchant.
    specified_coupon = Merchant.find(params[:merchant_id]).coupons.find(params[:id])

    #NOTE: Need to add count functionality here! (model method AND serializer)

    # binding.pry

    #Don't know if there's an easier way to do this, e.g. .new(specified_coupon, :times_used) or something...
    render json: CouponSerializer.new(specified_coupon, { params: { display_count: true } })
  end

  def create
    #Create new coupon, but check things first:

    if !Coupon.verify_unique_code(params[:code])
      render json: { data: "You must specify a unique code" }, status: :unprocessable_entity
      #Fancier: could return a suggestion for a unique code in the JSON response...
      return
    end

    #Check that discount_value XOR discount_percentage is provided
    #This is my attempt at creating a proper XOR operator here (coerce to boolean, then usual XOR)
    #Not the most readable, though...so perhaps change it back?
    if !(!!params[:discount_value] ^ !!params[:discount_percentage])
      render json: { data: "Ya can't set neither nor both value and percentage at once, fool!"}, status: :unprocessable_entity
      return
    end


    #Now we're ready to find the associated merchant and create:

    #First, look up spceified merchant (and verify success)
    merchant = Merchant.find(params[:merchant_id])

    #Check for number of current active coupons
    if params[:status] == true && merchant.find_number_active_coupons >= 5
      #We gots a prob
      render json: { data: "Houston, we have a problem" }, status: :unprocessable_entity
      # Merchant.find(params[:merchant_id])
    else
      #NOTE: failing validation due to nonexistant merchant.  I assume it's because of coupon_params_create()...
      # new_coupon = Coupon.create!(coupon_params_create)
      # params.permit!
      # new_coupon = Coupon.create!(params)
      #GOOD GRIEF THAT TOOK LONGER TO DO THAN I WANT TO ADMIT...
      new_coupon = Merchant.find(params[:merchant_id]).coupons.create!(coupon_params_create)

      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end

  def update
    #NOTE: for now, this will ONLY update 'status' via a query.
    #TO ASK: should we even allow changing other things?  You're kinda messing with the 'identity' of the coupon at that point...

    #WEIRD: this will run up here, but apparently not down within the if/else logic?!?!!

    # updated_coupon = Coupon.update!(params[:id], coupon_params_update)

    # binding.pry

    if params[:status]
      coupon = Coupon.find(params[:id])
      coupon.set_status(params[:status])

      if params[:status] == "active" && coupon.status == false
        if coupon.merchant.find_number_active_coupons >= 5
          render json: { data: "too many active already yo" }, status: :unprocessable_entity
        else
          #Activate it!
          # coupon.update!(coupon_params_update)
          #Here it is throwing an error...why?
          params[:status] = true
          updated_coupon = Coupon.update!(params[:id], coupon_params_update)
          render json: { data: "Coupon activated" }
        end
      elsif params[:status] == "inactive" && coupon.status == true

        # binding.pry

        if coupon.pending_invoices?
          render json: { data: "Ya can't deactivate it 'til it's processed, man!" }, status: :unprocessable_entity
        else
          #Deactivate it!
          params[:status] = false
          updated_coupon = Coupon.update!(params[:id], coupon_params_update)
          render json: { data: "Coupon deactivated" }
        end
      else
        #Either nothing was changed, or got a bad input string here, generate an appropriate error
        render json: { data: "uh oh, hit the else" }, status: 404
      end

    end

  end

  private

  def coupon_params_create
    params.require(:coupon).permit(:name, :code, :status, :discount_value, :discount_percentage, :merchant_id)
  end
  
  def coupon_params_update
    #Might allow more params later, but this is all we need for now...
    # params.require(:coupon).permit(:status, :name)
    # params.permit(:status, :name)
    params.permit(:status)
  end

  #Later: refactor into main class (esp since this repeats MerchantController exactly)
  def coupon_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Coupon not found"), status: :not_found
  end

end