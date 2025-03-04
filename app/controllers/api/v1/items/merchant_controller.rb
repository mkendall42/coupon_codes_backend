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
    render json: ErrorSerializer.handle_exception(exception, "Your request for returning merchant associated with item could not be completed"), status: :not_found
  end
end