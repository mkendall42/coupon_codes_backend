class Api::V1::Merchants::SearchController < ApplicationController

  def find_all
    if params[:name].blank?
      render json: ErrorSerializer.search_parameters_error("Parameter 'name' cannot be empty"), status: :unprocessable_entity
      return
    end

    merchants = Merchant.find_by_name_string(params[:name])

    render json: MerchantSerializer.new(merchants)
  end
end