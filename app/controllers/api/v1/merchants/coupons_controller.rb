class Api::V1::Merchants::CouponsController < ApplicationController
  #Handles coupon related queries belonging to a merchant (hence the namespace)

  def index
    #Find and render all coupons for merchant.
    #Will need to handle potential exceptions here

    # binding.pry

    # merchant_coupons = Merchant.find(params[:id]).coupons
    merchant_coupons = Merchant.find(params[:merchant_id]).coupons

    #Will need a new serializer for this
    render json: CouponSerializer.new(merchant_coupons)

  end

end