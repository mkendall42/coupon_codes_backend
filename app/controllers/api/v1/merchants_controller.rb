class Api::V1::MerchantsController < ApplicationController

  def index
    if params[:sorted] == "age"
      merchants = Merchant.sorted_by_age
    else
      merchants = Merchant.all
    end

    render json: MerchantSerializer.new(merchants)
  end

end