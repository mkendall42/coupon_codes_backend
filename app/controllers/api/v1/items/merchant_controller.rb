class Api::V1::Items::MerchantController < ApplicationController
  #This specifically controls the /api/v1/items/:id/merchant endpoint
  # rescue_from ActiveRecord::RecordNotFound, with: merchant_not_found

  def index
    begin
      specified_item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error

      # binding.pry

      render json: {
        message: "Your request could not be completed.",
        errors: [ { message: error.message } ]
      }, status: 404

      return
    end

    begin
      associated_merchant = specified_item.merchant
    rescue ActiveRecord::RecordNotFound => error
      render json: {
        message: "Your request could not be completed.",
        errors: [ { message: error.message } ]
      }, status: 404

      return
    end

    render json: MerchantSerializer.new(associated_merchant)
    
  end

  private

  # def merchant_not_found
  #   #Render appropriate JSON
  # end
end