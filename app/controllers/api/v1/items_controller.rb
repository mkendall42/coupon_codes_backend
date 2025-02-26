class Api::V1::ItemsController < ApplicationController

  def update
    updated_item = Item.update(params[:id], item_update_params)

    render json: ItemSerializer.new(updated_item)
  end


  private

  #For strong params checking and helper methods later
  def item_update_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
  
end