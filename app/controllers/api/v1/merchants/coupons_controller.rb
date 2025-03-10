class Api::V1::Merchants::CouponsController < ApplicationController
  #Handles coupon related queries belonging to a merchant (hence the namespace)
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_not_found

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

    #NOTE: Need to add count functionality here!
    
    render json: CouponSerializer.new(specified_coupon)
  end


  private

  #Later: refactor into main class (esp since this repeats MerchantController exactly)
  def merchant_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Merchant not found"), status: :not_found
  end

end