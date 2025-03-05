class Api::V1::MerchantInvoicesController < ApplicationController
  def index
    if !params[:status].present?
      render json: ErrorSerializer.search_parameters_error("Only valid query parameter is 'status='"), status: :unprocessable_entity
      return
    elsif !["returned", "shipped", "packaged"].include?(params[:status])
      render json: ErrorSerializer.search_parameters_error("Only valid values for 'status' query are 'returned', 'shipped', or 'packaged'"), status: :unprocessable_entity
      return
    else
      merchant = Merchant.find(params[:merchant_id])
      invoices = merchant.invoices.filter_by_status(params[:status])
    end

    render json: InvoiceSerializer.new(invoices)
  end
end