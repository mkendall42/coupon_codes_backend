class Api::V1::Items::SearchController < ApplicationController
  def find
    if params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      return render json: ErrorSerializer.search_parameters_error("Cannot send both name and price parameters"), status: 400
    end

    if params[:name].present?
      item = Item.find_by_name_string(params[:name])
      if item
        render json: ItemSerializer.new(item)
      else
        render json: ErrorSerializer.no_item_matched("No item exists with name containing search string"), status: :not_found
      end

    elsif params[:min_price].present? || params[:max_price].present?

      if params[:min_price].to_f < 0 || params[:max_price].to_f < 0
        return render json: { errors: "Min/max issue" }, status: 400
      end
  
      item = Item.find_by_price_range(params[:min_price], params[:max_price])

      if item
        render json: ItemSerializer.new(item)
      elsif params[:min_price] && params[:max_price] && (params[:max_price] < params[:min_price])
        render json: ErrorSerializer.no_item_matched("Cannot have max_price less than min_price"), status: :not_found
      else
        render json: ErrorSerializer.no_item_matched("No item exists within specified price range"), status: :not_found
      end

    else
      render json: ErrorSerializer.search_parameters_error("Parameter 'name' or 'min_price/max_price' must be provided"), status: :unprocessable_entity
    end
  end
end