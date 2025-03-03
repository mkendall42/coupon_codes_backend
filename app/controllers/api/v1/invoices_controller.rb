class Api::V1::InvoicesController < ApplicationController
  def index
    if params[:merchant_id].present?
      merchant = Merchant.find(params[:merchant_id])
      invoices = merchant.invoices.filter_by_status(params[:status])
    else
      invoices = Invoices.all
    end

    render json: InvoiceSerializer.new(invoices)
  end
end