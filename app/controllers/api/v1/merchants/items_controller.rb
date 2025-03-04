class Api::V1::Merchants::ItemsController < ApplicationController
  #This specifically controls the /api/v1/merchants/:id/items endpoint
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_not_found

  def index
    specified_merchant = Merchant.find(params[:id])
    items_of_merchant = specified_merchant.items
    render json: ItemSerializer.new(items_of_merchant)
  end

  private

  def merchant_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Your request for returning items associated with merchant could not be completed"), status: :not_found
  end

end
