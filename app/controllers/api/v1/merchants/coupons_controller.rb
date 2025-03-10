class Api::V1::Merchants::CouponsController < ApplicationController
  #Handles coupon related queries belonging to a merchant (hence the namespace)
  rescue_from ActiveRecord::RecordNotFound, with: :coupon_not_found

  def index
    #Find and render all coupons for merchant.
    #Will need to handle potential exceptions here

    # binding.pry

    # merchant_coupons = Merchant.find(params[:id]).coupons
    merchant_coupons = Merchant.find(params[:merchant_id]).coupons

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
    #1) error if code ! unique
    #2) error if attempting to create active coupon with >= 5 already active

    #Check code uniqueness - ADD LATER
    # if params[:code]

    #Check that discount_value XOR discount_percentage is provided
    #This is my attempt at creating a proper XOR operator here (coerce to boolean, then usual XOR)
    #Not the most readable, though...so perhaps change it back?
    if !(!!params[:discount_value] ^ !!params[:discount_percentage])
      render json: { data: "Ya can't set neither nor both value and percentage at once, fool!"}, status: :unprocessable_entity
      return
    end

    binding.pry

    #First, look up spceified merchant (and verify success)
    merchant = Merchant.find(params[:merchant_id])

    #Check for number of current active coupons
    if params[:status] == true && merchant.find_number_active_coupons >= 5
      #We gots a prob
      render json: { data: "Houston, we have a problem" }, status: :unprocessable_entity
      # Merchant.find(params[:merchant_id])
    else
      #NOTE: failing validation due to nonexistant merchant.  I assume it's because of coupon_params()...
      # new_coupon = Coupon.create!(coupon_params)
      # params.permit!
      # new_coupon = Coupon.create!(params)
      #GOOD GRIEF THAT TOOK LONGER TO DO THAN I WANT TO ADMIT...
      new_coupon = Merchant.find(params[:merchant_id]).coupons.create!(coupon_params)

      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :status, :discount_value, :discount_percentage, :merchant_id)
  end

  #Later: refactor into main class (esp since this repeats MerchantController exactly)
  def coupon_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Coupon not found"), status: :not_found
  end

end