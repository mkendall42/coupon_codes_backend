class Api::V1::ItemsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :item_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_parameters_error

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
    render json: ItemSerializer.new(item)
  end

  def create
    item = Item.create!(item_update_params) 
    render json: ItemSerializer.new(item), status: :created 
  end

  
  def update
    updated_item = Item.update!(params[:id], item_update_params)

    render json: ItemSerializer.new(updated_item)
  end

  def destroy
    render json: Item.destroy(params[:id]), status: 204
  end

  private

  #For strong params checking and helper methods later
  def item_update_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def item_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Item not found"), status: :not_found
  end

  def parameter_missing_error(exception)
    render json: ErrorSerializer.handle_exception(exception, "Item was not created"), status: :unprocessable_entity
  end
  
  def invalid_parameters_error(exception)
    # binding.pry

    render json: ErrorSerializer.handle_exception(exception, "Item was not created"), status: :unprocessable_entity
  end
end