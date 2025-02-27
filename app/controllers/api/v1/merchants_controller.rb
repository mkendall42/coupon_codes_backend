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
  
  def update
    updated_merchant = Merchant.update(params[:id], merchant_update_params)

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

end