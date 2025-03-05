class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

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
    #Changed delete() -> destroy() to properly trigger cascade deletions (this was hiding a while, argh!)
    render json: Merchant.destroy(params[:id]), status: 204
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
    #The following first render line is hacky, but is specifically to keep our DRY code intact while adhering to the exact expectations of the Postman script tests
    #(Here they expect a body with only message and errors keys, while typically they expect a parent data key - hence the implementation in ErrorSerializer)
    if exception.message == "param is missing or the value is empty: merchant"
      render json: { message: "Merchant was not created", errors: ["param is missing or the value is empty: merchant"]}, status: :unprocessable_entity
    else
      render json: ErrorSerializer.handle_exception(exception, "Merchant was not created"), status: :unprocessable_entity
    end
  end

end