class Api::V1::Items::SearchController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :item_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

  def find
    if params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      return render json: { error: "Cannot send both name and price parameters" }, status: :unprocessable_entity
    end

    if params[:name].present?
      item = Item.where("name ILIKE ?", "%#{params[:name]}%").order(:name).first
      if item
        render json: ItemSerializer.new(item)
      else
        render json: { error: "Item not found" }, status: :not_found
      end

    elsif params[:min_price].present? || params[:max_price].present?
      min_price = params[:min_price].to_f if params[:min_price].present?
      max_price = params[:max_price].to_f if params[:max_price].present?

      items = Item.all
      items = items.where("unit_price >= ?", min_price) if min_price
      items = items.where("unit_price <= ?", max_price) if max_price
      item = items.order(:name).first

      if item
        render json: ItemSerializer.new(item)
      else
        render json: { error: "Item not found" }, status: :not_found
      end

    else
      render json: { error: "Parameter 'name' or 'min_price/max_price' must be provided" }, status: :unprocessable_entity
    end
  end

  private

  def item_not_found
    render json: { errors: "Item not found" }, status: :not_found
  end

  def parameter_missing_error
    render json: { error: "Item was not created" }, status: :unprocessable_entity
  end
end