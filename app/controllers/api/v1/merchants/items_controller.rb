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
    #Render appropriate JSON.  For now keep basic.  Later: pass more args (e.g. for 'message' key, etc.)?
    render json: {
      message: "Your request could not be completed.",
      errors: [ { message: exception.message } ]
    }, status: 404
  end

end
