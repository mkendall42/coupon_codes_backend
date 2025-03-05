class Api::V1::Items::SearchController < ApplicationController
  # rescue_from ActiveRecord::RecordNotFound, with: :item_not_found
  # rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

  def find
    if params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      #UPDATE
      return render json: ErrorSerializer.search_parameters_error("Cannot send both name and price parameters"), status: :unprocessable_entity
      # return render json: { error: "Cannot send both name and price" }, status: :unprocessable_entity
    end

    if params[:name].present?
      #UPDATE - potential MVC infraction
      item = Item.find_by_name_string(params[:name])
      # item = Item.where("name ILIKE ?", "%#{params[:name]}%").order(:name).first
      if item
        render json: ItemSerializer.new(item)
      else
        render json: ErrorSerializer.no_item_matched("No item exists with name containing search string"), status: :not_found
      end

    elsif params[:min_price].present? || params[:max_price].present?
      # min_price = params[:min_price].to_f if params[:min_price].present?
      # max_price = params[:max_price].to_f if params[:max_price].present?

      #Move these lines into model method!
      item = Item.find_by_price_range(params[:min_price], params[:max_price])

      # items = Item.all
      # items = items.where("unit_price >= ?", min_price) if min_price
      # items = items.where("unit_price <= ?", max_price) if max_price
      # item = items.order(:name).first

      #IMPORTANT: check for max < min 

      if item
        render json: ItemSerializer.new(item)
      else
        render json: ErrorSerializer.no_item_matched("No item exists within specified price range"), status: :not_found
        # render json: { error: "Item not found" }, status: :not_found
        # item_not_found(exception - shoot need to define this)
      end

    else
      render json: ErrorSerializer.search_parameters_error("Parameter 'name' or 'min_price/max_price' must be provided"), status: :unprocessable_entity
      # render json: { error: "Parameter 'name' or 'min_price/max_price' must be provided" }, status: :unprocessable_entity
    end
  end

  private

  # def item_not_found(exception)
  #   #NOTE: these aren't even getting hit
  #   binding.pry

  #   render json: ErrorSerializer.handle_exception(exception, "Item not found"), status: :not_found
  # end

  # def parameter_missing_error(exception)
  #   #NOTE: these aren't even getting hit
  #   binding.pry

  #   render json: ErrorSerializer.handle_exception(exception, "Item was not created"), status: :unprocessable_entity
  # end
end