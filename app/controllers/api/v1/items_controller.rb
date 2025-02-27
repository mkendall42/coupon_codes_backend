class Api::V1::ItemsController < ApplicationController
  def index
    if params[:sorted] == "price"
      items = Item.sorted_by_price
    else
      items = Item.all
    end

    render json: ItemSerializer.new(items)
  end


  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item), status: :ok
  end

  def create
    item = Item.create!(item_params) 
    render json: ItemSerializer.new(item), status: :created
  end

  
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