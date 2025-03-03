class Api::V1::Items::MerchantController < ApplicationController
  #This specifically controls the /api/v1/items/:id/merchant endpoint
  rescue_from ActiveRecord::RecordNotFound, with: :item_not_found

  def index
    specified_item = Item.find(params[:id])
    associated_merchant = specified_item.merchant

    render json: MerchantSerializer.new(associated_merchant)
  end

  private

  def item_not_found(exception)
    #Render appropriate JSON.  For now keep basic.  Later: pass more args (e.g. for 'message' key, etc.)?
    render json: {
      message: "Your request could not be completed.",
      errors: [ { message: exception.message } ]
    }, status: 404
  end
end