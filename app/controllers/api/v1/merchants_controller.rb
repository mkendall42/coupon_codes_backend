class Api::V1::MerchantsController < ApplicationController
  def index
    if params[:sorted] == "age"
      merchants = Merchant.sorted_by_age
    else
      merchants = Merchant.all
    end
    
    if params[:status] == "returned"
      merchants = Merchant.has_returned_items
    end

    #also need returned and count values

    render json: MerchantSerializer.new(merchants)
  end

  rescue_from ActiveRecord::RecordNotFound, with: :merchant_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def create
    if params[:merchant].blank?
      raise ActionController::ParameterMissing, "Merchant parameters are missing or empty"
    end
    merchant = Merchant.create!(merchant_update_params) 
    render json: MerchantSerializer.new(merchant), status: :created
  end

  
  def update
    updated_merchant = Merchant.update(params[:id], merchant_update_params)

    render json: MerchantSerializer.new(updated_merchant)
  end


  private

  def merchant_update_params
    #Only accept name as updateable (per requirements)
    params.require(:merchant).permit(:name)
  end

  def merchant_not_found
    render json: { error: "Merchant not found" }, status: :not_found
  end

  def parameter_missing_error(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

end