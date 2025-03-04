class Api::V1::MerchantCustomersController < ApplicationController
  def index
    if params[:merchant_id].present?
      merchant = Merchant.find(params[:merchant_id])
      customers = merchant.customers
    else
      customers = Customer.all
    end
    render json: CustomerSerializer.new(customers)
  end
end