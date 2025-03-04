class Api::V1::Merchants::SearchController < ApplicationController

  def find_all
    if params[:name].blank?
      render json: { error: "Parameter 'name' cannot be empty" }, status: :unprocessable_entity
      return
    end

    merchants = Merchant.where("name ILIKE ?", "%#{params[:name]}%").order(:name)

    render json: MerchantSerializer.new(merchants)
  end
end