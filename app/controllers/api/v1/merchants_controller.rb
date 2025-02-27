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

    render json: MerchantSerializer.new(merchants, { params: { count: params[:count] } })
  end
end