class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

  #Things to do:
  #1. Check the update action (and use update!())
  #2. Decide on exact error handling.  Do this with exception handler methods, or custom serializers?

  def index
    if params[:sorted] == "age"
      merchants = Merchant.sorted_by_age
    else
      merchants = Merchant.all
    end
    
    if params[:status] == "returned"
      merchants = Merchant.has_returned_items
    end

    render json: MerchantSerializer.new(merchants, { params: { count: params[:count] } })
  end

  
  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def create
    merchant = Merchant.create!(merchant_update_params) 
    render json: MerchantSerializer.new(merchant), status: :created
  end

  
  def update
    updated_merchant = Merchant.update!(params[:id], merchant_update_params)

    render json: MerchantSerializer.new(updated_merchant)
  end

  def destroy
    render json: Merchant.delete(params[:id]), status: 204
  end

  private

  def merchant_update_params
    #Only accept name as updateable (per requirements)
    params.require(:merchant).permit(:name)
  end

  def merchant_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Merchant not found"), status: :not_found
    # render json: { error: "Merchant not found" }, status: :not_found
  end

  def parameter_missing_error(exception)
    #NEEDS UPDATING
    #NOTE: do we actually need this / does anything use it?
    render json: ErrorSerializer.handle_exception(exception, "Merchant was not created"), status: :unprocessable_entity
    # render json: { error: "Merchant was not created" }, status: :unprocessable_entity
  end

end