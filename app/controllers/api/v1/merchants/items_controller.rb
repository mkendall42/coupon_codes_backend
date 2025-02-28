class Api::V1::Merchants::ItemsController < ApplicationController
  #This specifically controls the /api/v1/merchants/:id/items endpoint

  def index
    #Need to implement exception handling here (otherwise will not proceed)
    #NOTE: refactor later to comply with rescue_from
    begin
      specified_merchant = Merchant.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error

      # binding.pry

      render json: {
        # status: "404",
        message: "Your request could not be completed.",
        errors: [ { message: error.message } ]
      }, status: 404

      return
      #Is there a better way to do this?
    end

    items_of_merchant = specified_merchant.items
    render json: ItemSerializer.new(items_of_merchant)
  end
end
